# VPC Module
module "vpc" {
  source = "./modules/vpc"

  project_name         = var.project_name
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  enable_nat_gateway   = var.enable_nat_gateway
  enable_flow_logs     = var.enable_vpc_flow_logs
  
  tags = var.tags
}

# ECR Repository
module "ecr" {
  source = "./modules/ecr"

  repository_name      = "${var.project_name}-ecr"
  image_tag_mutability = var.ecr_image_tag_mutability # default "MUTABLE"
  scan_on_push         = var.ecr_scan_on_push # default true

  lifecycle_policy = var.ecr_lifecycle_policy # 10 images retention

  tags = var.tags
}

# IAM Roles for CodeDeploy and GitHub Actions
module "iam" {
  source = "./modules/iam"

  create_codedeploy_role      = true
  codedeploy_role_name        = "${var.project_name}-codedeploy-role"
  
  create_github_oidc_provider = var.enable_github_oidc
  create_github_actions_role  = var.enable_github_oidc
  github_actions_role_name    = "${var.project_name}-github-actions-role"
  github_repo                 = var.github_repo

  ecs_task_execution_role_arn = module.ecs.task_execution_role_arn
  ecs_task_role_arn           = module.ecs.task_role_arn

  enable_s3_access = false

  tags = var.tags
}

# Security Groups
module "alb_sg" {
  source = "./modules/sg"

  vpc_id      = module.vpc.vpc_id
  sg_name     = "${var.project_name}-alb-sg"
  description = "Security group for Application Load Balancer"

  ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow HTTP from internet"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow HTTPS from internet"
    },
    {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow test traffic for Blue/Green deployment"
    }
  ]

  tags = var.tags
}

module "ecs_sg" {
  source = "./modules/sg"

  vpc_id      = module.vpc.vpc_id
  sg_name     = "${var.project_name}-ecs-sg"
  description = "Security group for ECS tasks"

  ingress_rules = [
    {
      from_port                = 3000
      to_port                  = 3000
      protocol                 = "tcp"
      source_security_group_id = module.alb_sg.security_group_id
      description              = "Allow HTTP from ALB"
    }
  ]

  tags = var.tags
}

module "rds_sg" {
  source = "./modules/sg"

  vpc_id      = module.vpc.vpc_id
  sg_name     = "${var.project_name}-rds-sg"
  description = "Security group for RDS"

  ingress_rules = [
    {
      from_port                = 5432
      to_port                  = 5432
      protocol                 = "tcp"
      source_security_group_id = module.ecs_sg.security_group_id
      description              = "Allow PostgreSQL from ECS"
    },
    {
      from_port                = 5432
      to_port                  = 5432
      protocol                 = "tcp"
      source_security_group_id = module.ec2_sg.security_group_id
      description              = "Allow PostgreSQL from EC2"
    },
    {
      from_port                = 5432
      to_port                  = 5432
      protocol                 = "tcp"
      cidr_blocks             = ["218.239.246.16/32"]
      description              = "Allow PostgreSQL from SCIT"
    },
  ]

  tags = var.tags
}

module "bastion_rds_sg" {
  source = "./modules/sg"

  vpc_id      = module.vpc.vpc_id
  sg_name     = "${var.project_name}-bastion-rds-sg"
  description = "Security group for RDS for Bastion"

  ingress_rules = [
    {
      from_port                = 5432
      to_port                  = 5432
      protocol                 = "tcp"
      source_security_group_id = module.ec2_sg.security_group_id
      description              = "Allow PostgreSQL from EC2"
    },
    {
      from_port                = 5432
      to_port                  = 5432
      protocol                 = "tcp"
      cidr_blocks             = ["218.239.246.16/32"]
      description              = "Allow PostgreSQL from SCIT"
    },

  ]

  tags = var.tags
}

module "ec2_sg" {
  source = "./modules/sg"

  vpc_id      = module.vpc.vpc_id
  sg_name     = "${var.project_name}-ec2-sg"
  description = "Security group for EC2 instances"

  ingress_rules = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"] # Best practice: restrict to your IP
      description = "Allow SSH"
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow HTTP"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow HTTPS"
    }
  ]

  tags = var.tags
}

# SSM Parameter Store
module "ssm" {
  source = "./modules/ssm"

  project_name = var.project_name

  parameters = {
    db_host = {
      name        = "/${var.project_name}/${var.environment}/db/host"
      value       = module.rds.db_instance_address
      type        = "String"
      description = "Database host address"
    }
    db_port = {
      name        = "/${var.project_name}/${var.environment}/db/port"
      value       = tostring(module.rds.db_instance_port)
      type        = "String"
      description = "Database port"
    }
    db_name = {
      name        = "/${var.project_name}/${var.environment}/db/name"
      value       = module.rds.db_instance_name
      type        = "String"
      description = "Database name"
    }
    db_username = {
      name        = "/${var.project_name}/${var.environment}/db/username"
      value       = var.rds_master_username
      type        = "SecureString"
      description = "Database username"
    }
    db_password = {
      name        = "/${var.project_name}/${var.environment}/db/password"
      value       = var.rds_master_password
      type        = "SecureString"
      description = "Database password"
    }
  }

  tags = var.tags
}

# RDS
module "rds" {
  source = "./modules/rds"

  identifier     = "${var.project_name}-db"
  engine         = var.rds_engine # postgreSQL
  engine_version = var.rds_engine_version
  instance_class = var.rds_instance_class

  allocated_storage = var.rds_allocated_storage
  database_name     = var.rds_database_name
  master_username   = var.rds_master_username
  master_password   = var.rds_master_password

  vpc_security_group_ids = [module.rds_sg.security_group_id]
  subnet_ids             = module.vpc.private_subnet_ids

  multi_az               = true # Set to true for production
  deletion_protection    = true # Set to true for production
  skip_final_snapshot    = false  # Set to false for production

  backup_retention_period = 7
  
  tags = var.tags
}

# RDS
module "bastion_rds" {
  source = "./modules/rds"

  identifier     = "${var.project_name}-bastion-db"
  engine         = var.rds_engine # postgreSQL
  engine_version = var.rds_engine_version
  instance_class = var.rds_instance_class

  allocated_storage = var.rds_allocated_storage
  database_name     = var.rds_database_name
  master_username   = var.rds_master_username
  master_password   = var.rds_master_password

  publicly_accessible = true

  vpc_security_group_ids = [module.bastion_rds_sg.security_group_id]
  subnet_ids             = module.vpc.public_subnet_ids

  multi_az               = false # Set to true for production
  deletion_protection    = false # Set to true for production
  skip_final_snapshot    = true  # Set to false for production

  backup_retention_period = 7
  
  tags = var.tags
}

# Application Load Balancer
module "alb" {
  source = "./modules/alb"

  alb_name           = "${var.project_name}-alb"
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.public_subnet_ids
  security_group_ids = [module.alb_sg.security_group_id]

  target_type  = "ip"
  target_port  = var.container_port # 80. ECS container port

  health_check_path     = var.alb_health_check_path
  health_check_interval = 30
  health_check_timeout  = 5

  enable_deletion_protection = false # Set to true for production
  enable_https_redirect      = true # Set to true if you have SSL certificate
  certificate_arn            = var.alb_certificate_arn

  create_test_listener = var.enable_blue_green_deployment

  tags = var.tags
}

# ECS
module "ecs" {
  source = "./modules/ecs"

  cluster_name = "${var.project_name}-cluster"
  aws_region   = var.aws_region

  create_task_definition = true
  task_family            = "${var.project_name}-app"
  task_cpu               = var.ecs_task_cpu
  task_memory            = var.ecs_task_memory
  container_name         = "app"
  container_image        = var.container_image != "" ? var.container_image : "${module.ecr.repository_url}:latest"
  container_port         = var.container_port # 80

  create_service             = true
  service_name               = "${var.project_name}-service"
  desired_count              = var.ecs_desired_count
  deployment_controller_type = var.enable_blue_green_deployment ? "CODE_DEPLOY" : "ECS"
  subnet_ids                 = module.vpc.private_subnet_ids
  security_group_ids         = [module.ecs_sg.security_group_id]
  target_group_arn           = module.alb.blue_target_group_arn

  # Reference SSM parameters for database connection
  secrets = [
    {
      name      = "DB_HOST"
      valueFrom = module.ssm.parameter_arns["db_host"]
    },
    {
      name      = "DB_PORT"
      valueFrom = module.ssm.parameter_arns["db_port"]
    },
    {
      name      = "DB_NAME"
      valueFrom = module.ssm.parameter_arns["db_name"]
    },
    {
      name      = "DB_USERNAME"
      valueFrom = module.ssm.parameter_arns["db_username"]
    },
    {
      name      = "DB_PASSWORD"
      valueFrom = module.ssm.parameter_arns["db_password"]
    }
  ]

  enable_autoscaling = false

  tags = var.tags
}

# CodeDeploy for Blue/Green Deployment
module "codedeploy" {
  count  = var.enable_blue_green_deployment ? 1 : 0
  source = "./modules/codedeploy"

  application_name       = "${var.project_name}-app"
  deployment_group_name  = "${var.project_name}-deployment-group"
  codedeploy_role_arn    = module.iam.codedeploy_role_arn
  deployment_config_name = var.codedeploy_deployment_config

  ecs_cluster_name = module.ecs.cluster_name
  ecs_service_name = module.ecs.service_name

  blue_target_group_name  = module.alb.blue_target_group_name
  green_target_group_name = module.alb.green_target_group_name

  prod_listener_arns = [module.alb.https_listener_arn]
  test_listener_arns = module.alb.test_listener_arn != null ? [module.alb.test_listener_arn] : []

  auto_rollback_enabled = true
  auto_rollback_events  = ["DEPLOYMENT_FAILURE", "DEPLOYMENT_STOP_ON_ALARM"]

  deployment_ready_action    = var.codedeploy_deployment_ready_action
  terminate_blue_action      = "TERMINATE"
  termination_wait_time      = 5

  tags = var.tags

  depends_on = [module.ecs]
}

# S3
module "s3" {
  source = "./modules/s3"

  bucket_name        = "${var.project_name}-${var.environment}-data-${data.aws_caller_identity.current.account_id}"
  enable_versioning  = var.s3_enable_versioning

  lifecycle_rules = [
    {
      id      = "archive-old-versions"
      enabled = true
      transitions = [
        {
          days          = 30
          storage_class = "STANDARD_IA"
        },
        {
          days          = 90
          storage_class = "GLACIER"
        }
      ]
      noncurrent_version_expiration = {
        days = 90
      }
    }
  ]

  tags = var.tags
}

# SNS Topic for Alerts
module "sns_temp" {
  source = "./modules/sns"

  topic_name   = "${var.project_name}-sns-temp"
  display_name = "Temporary SNS"

  subscriptions = var.alert_email != "" ? [
    {
      protocol = "email"
      endpoint = var.alert_email
    }
  ] : []

  tags = var.tags
}

# EC2 (Optional - for bastion or management)
module "ec2" {
  source = "./modules/ec2"

  instance_name = "${var.project_name}-bastion"
  instance_type = var.ec2_instance_type
  
  subnet_id          = module.vpc.public_subnet_ids[0]
  security_group_ids = [module.ec2_sg.security_group_id]
  key_name           = var.ec2_key_name # this requires an existing key pair in AWS EC2 Console

  root_volume_encrypted = true
  
  tags = var.tags
}

# Data source for current AWS account
data "aws_caller_identity" "current" {}