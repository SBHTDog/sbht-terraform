# VPC Outputs
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

# EC2 Outputs
output "ec2_instance_id" {
  description = "The ID of the EC2 instance"
  value       = module.ec2.instance_id
}

output "ec2_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = module.ec2.instance_public_ip
}

output "ec2_private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = module.ec2.instance_private_ip
}

# ECR Outputs
output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = module.ecr.repository_url
}

output "ecr_repository_name" {
  description = "Name of the ECR repository"
  value       = module.ecr.repository_name
}

# ALB Outputs
output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.alb.alb_dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the ALB (for Route53)"
  value       = module.alb.alb_zone_id
}

output "blue_target_group_arn" {
  description = "ARN of the blue (production) target group"
  value       = module.alb.blue_target_group_arn
}

output "green_target_group_arn" {
  description = "ARN of the green target group"
  value       = module.alb.green_target_group_arn
}

# RDS Outputs
output "rds_endpoint" {
  description = "The connection endpoint for the RDS instance"
  value       = module.rds.db_instance_endpoint
  sensitive   = true
}

output "rds_database_name" {
  description = "The name of the database"
  value       = module.rds.db_instance_name
}

# ECS Outputs
output "ecs_cluster_name" {
  description = "The name of the ECS cluster"
  value       = module.ecs.cluster_name
}

output "ecs_cluster_arn" {
  description = "The ARN of the ECS cluster"
  value       = module.ecs.cluster_arn
}

output "ecs_service_name" {
  description = "The name of the ECS service"
  value       = module.ecs.service_name
}

# S3 Outputs
output "s3_bucket_name" {
  description = "The name of the S3 bucket"
  value       = module.s3.bucket_id
}

output "s3_bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = module.s3.bucket_arn
}

# SNS Outputs
output "sns_topic_arn" {
  description = "The ARN of the SNS topic"
  value       = module.sns_temp.topic_arn
}

# SSM Outputs
output "ssm_parameter_arns" {
  description = "Map of SSM parameter ARNs"
  value       = module.ssm.parameter_arns
  sensitive   = true
}

# IAM Outputs
output "codedeploy_role_arn" {
  description = "ARN of the CodeDeploy IAM role"
  value       = module.iam.codedeploy_role_arn
}

output "github_actions_role_arn" {
  description = "ARN of the GitHub Actions IAM role (for OIDC)"
  value       = module.iam.github_actions_role_arn
}

output "github_oidc_provider_arn" {
  description = "ARN of the GitHub OIDC provider"
  value       = module.iam.github_oidc_provider_arn
}

# CodeDeploy Outputs
output "codedeploy_application_name" {
  description = "Name of the CodeDeploy application"
  value       = var.enable_blue_green_deployment ? module.codedeploy[0].application_name : null
}

output "codedeploy_deployment_group_name" {
  description = "Name of the CodeDeploy deployment group"
  value       = var.enable_blue_green_deployment ? module.codedeploy[0].deployment_group_name : null
}

# Security Group Outputs
output "alb_security_group_id" {
  description = "Security group ID for ALB"
  value       = module.alb_sg.security_group_id
}

output "ecs_security_group_id" {
  description = "Security group ID for ECS"
  value       = module.ecs_sg.security_group_id
}

output "rds_security_group_id" {
  description = "Security group ID for RDS"
  value       = module.rds_sg.security_group_id
}

output "ec2_security_group_id" {
  description = "Security group ID for EC2"
  value       = module.ec2_sg.security_group_id
}
