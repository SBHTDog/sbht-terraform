variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-northeast-2"
}

variable "project_name" { # set in terraform cloud
  description = "Project name for resource naming and tagging"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["ap-northeast-2a", "ap-northeast-2c"]
}

# VPC Configuration
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = true
}

variable "enable_vpc_flow_logs" {
  description = "Enable VPC Flow Logs"
  type        = bool
  default     = true
}

# EC2 Configuration
variable "ec2_instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ec2_key_name" {
  description = "EC2 key pair name for SSH access"
  type        = string
  default     = null
}

# RDS Configuration
variable "rds_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "rds_allocated_storage" {
  description = "RDS allocated storage in GB"
  type        = number
  default     = 20
}

variable "rds_engine" {
  description = "RDS database engine"
  type        = string
  default     = "postgres"
}

variable "rds_engine_version" {
  description = "RDS engine version"
  type        = string
  default     = "15.4"
}

variable "rds_database_name" {
  description = "Name of the database to create"
  type        = string
  default     = "appdb"
}

variable "rds_master_username" {
  description = "Master username for RDS"
  type        = string
  default     = "dbadmin"
  sensitive   = true
}

variable "rds_master_password" {
  description = "Master password for RDS"
  type        = string
  sensitive   = true
  validation {
    condition     = length(var.rds_master_password) >= 8
    error_message = "RDS password must be at least 8 characters long."
  }
}

# ECS Configuration
variable "ecs_task_cpu" {
  description = "ECS task CPU units"
  type        = string
  default     = "256"
}

variable "ecs_task_memory" {
  description = "ECS task memory (MiB)"
  type        = string
  default     = "512"
}

variable "ecs_desired_count" {
  description = "Desired number of ECS tasks"
  type        = number
  default     = 1
}

variable "container_image" {
  description = "Docker container image"
  type        = string
  default     = ""
}

variable "container_port" {
  description = "Port exposed by the container"
  type        = number
  default     = 80
}

# ECR Configuration
variable "ecr_image_tag_mutability" {
  description = "Image tag mutability setting for ECR (MUTABLE or IMMUTABLE)"
  type        = string
  default     = "MUTABLE"
}

variable "ecr_scan_on_push" {
  description = "Enable image scanning on push to ECR"
  type        = bool
  default     = true
}

variable "ecr_lifecycle_policy" {
  description = "Lifecycle policy for ECR repository"
  type = list(object({
    rulePriority = number
    description  = string
    selection = object({
      tagStatus     = string
      tagPrefixList = optional(list(string))
      countType     = string
      countNumber   = number
    })
    action = object({
      type = string
    })
  }))
  default = [
    {
      rulePriority = 1
      description  = "Keep last 10 images"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 10
      }
      action = {
        type = "expire"
      }
    }
  ]
}

# ALB Configuration
variable "alb_health_check_path" {
  description = "Health check path for ALB target groups"
  type        = string
  default     = "/"
}

variable "alb_certificate_arn" {
  description = "ARN of ACM certificate for HTTPS listener"
  type        = string
  default     = null
}

# Blue/Green Deployment Configuration
variable "enable_blue_green_deployment" {
  description = "Enable Blue/Green deployment with CodeDeploy"
  type        = bool
  default     = true
}

variable "codedeploy_deployment_config" {
  description = "CodeDeploy deployment configuration name"
  type        = string
  default     = "CodeDeployDefault.ECSAllAtOnce"
}

variable "codedeploy_deployment_ready_action" {
  description = "Action when deployment is ready (CONTINUE_DEPLOYMENT or STOP_DEPLOYMENT)"
  type        = string
  default     = "CONTINUE_DEPLOYMENT"
}

# GitHub Actions OIDC Configuration
variable "enable_github_oidc" {
  description = "Enable GitHub Actions OIDC provider and role"
  type        = bool
  default     = false
}

variable "github_repo" {
  description = "GitHub repository in format 'owner/repo' for OIDC trust"
  type        = string
  default     = "SBHTDog/sbht-terraform"
}

# S3 Configuration
variable "s3_enable_versioning" {
  description = "Enable S3 bucket versioning"
  type        = bool
  default     = true
}

# Notification Configuration
variable "alert_email" {
  description = "Email address for CloudWatch alarms and notifications"
  type        = string
  default     = ""
}

# Common Tags
variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}