# Terraform AWS Infrastructure

A comprehensive Terraform project for deploying a production-ready AWS infrastructure with VPC, EC2, ECS, RDS, S3, SNS, and SSM Parameter Store.

## 🏗️ Architecture Overview

This project deploys a complete AWS infrastructure including:

- **VPC**: Multi-AZ VPC with public and private subnets, NAT Gateways, and VPC Flow Logs
- **Security Groups**: Properly configured security groups for ALB, ECS, RDS, and EC2
- **ECS**: Fargate-based container orchestration with auto-scaling capabilities
- **RDS**: PostgreSQL database with encryption, automated backups, and enhanced monitoring
- **S3**: Encrypted storage with versioning and lifecycle policies
- **SNS**: Notification system for alerts and monitoring
- **SSM Parameter Store**: Secure storage for configuration and secrets
- **EC2**: Optional bastion host for database access

## 📋 Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.5.0
- AWS CLI configured with appropriate credentials
- AWS account with necessary permissions

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone <repository-url>
cd terraform_study
```

### 2. Create a `terraform.tfvars` File

```hcl
aws_region    = "ap-northeast-2"
project_name  = "my-app"
environment   = "dev"

# EC2 Configuration
ec2_key_name = "my-keypair"  # Your EC2 key pair name

# RDS Configuration
rds_master_username = "dbadmin"
rds_master_password = "YourSecurePassword123!"  # Change this!

# Notification
alert_email = "your-email@example.com"

# Optional: Override defaults
# ecs_task_cpu    = "512"
# ecs_task_memory = "1024"
# container_image = "your-app:latest"
```

### 3. Initialize Terraform

```bash
terraform init
```

### 4. Review the Plan

```bash
terraform plan
```

### 5. Apply the Configuration

```bash
terraform apply
```

Type `yes` when prompted to create the infrastructure.

## 📁 Project Structure

```
.
├── main.tf                 # Main infrastructure configuration
├── variables.tf            # Input variables
├── outputs.tf              # Output values
├── provider.tf             # Provider and backend configuration
├── terraform.tfvars        # Variable values (create this file)
├── modules/
│   ├── vpc/               # VPC module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── sg/                # Security Group module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── ec2/               # EC2 module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── ecs/               # ECS module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── rds/               # RDS module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── s3/                # S3 module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── sns/               # SNS module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── ssm/               # SSM Parameter Store module
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
└── README.md              # This file
```

## 🔧 Configuration

### Key Variables

| Variable              | Description                         | Default           | Required |
| --------------------- | ----------------------------------- | ----------------- | -------- |
| `aws_region`          | AWS region to deploy resources      | `ap-northeast-2`  | No       |
| `project_name`        | Project name for resource naming    | `terraform-study` | No       |
| `environment`         | Environment name (dev/staging/prod) | `dev`             | No       |
| `rds_master_username` | RDS master username                 | `dbadmin`         | Yes      |
| `rds_master_password` | RDS master password                 | -                 | Yes      |
| `alert_email`         | Email for CloudWatch alarms         | -                 | No       |
| `ec2_key_name`        | EC2 key pair name                   | -                 | No       |
| `container_image`     | Docker image for ECS                | `nginx:latest`    | No       |

### Network Configuration

The default VPC CIDR is `10.0.0.0/16` with:

- Public subnets: `10.0.1.0/24`, `10.0.2.0/24`
- Private subnets: `10.0.11.0/24`, `10.0.12.0/24`

Modify `vpc_cidr` in `variables.tf` or override in `terraform.tfvars` to change.

## 🔐 Security Best Practices Implemented

### 1. **Network Security**

- ✅ Multi-AZ deployment with public and private subnets
- ✅ NAT Gateways for private subnet internet access
- ✅ VPC Flow Logs enabled for network monitoring
- ✅ Security groups with least privilege access

### 2. **Data Encryption**

- ✅ RDS storage encryption enabled by default
- ✅ S3 server-side encryption (AES256)
- ✅ SSM Parameter Store with SecureString type
- ✅ EC2 EBS volume encryption

### 3. **Access Control**

- ✅ IMDSv2 required for EC2 metadata access
- ✅ IAM roles for ECS tasks with minimal permissions
- ✅ Security group rules with specific source/destination
- ✅ RDS not publicly accessible

### 4. **Monitoring & Logging**

- ✅ CloudWatch Container Insights for ECS
- ✅ RDS Enhanced Monitoring
- ✅ RDS Performance Insights
- ✅ VPC Flow Logs to CloudWatch
- ✅ SNS alerts for failed notifications

### 5. **Backup & Recovery**

- ✅ RDS automated backups (7-day retention)
- ✅ S3 versioning enabled
- ✅ RDS final snapshot before deletion (production)
- ✅ S3 lifecycle policies for cost optimization

### 6. **High Availability**

- ✅ Multi-AZ subnets across availability zones
- ✅ RDS Multi-AZ option available (set `multi_az = true`)
- ✅ ECS auto-scaling configuration ready
- ✅ Application Load Balancer ready integration

## 📊 Outputs

After successful deployment, Terraform will output:

- VPC ID and subnet IDs
- EC2 instance details (ID, public/private IPs)
- RDS endpoint and database name
- ECS cluster and service information
- S3 bucket name and ARN
- SNS topic ARN
- Security group IDs

Access outputs with:

```bash
terraform output
terraform output -json
terraform output vpc_id
```

## 🔄 Updating Infrastructure

1. Modify your `.tf` files or `terraform.tfvars`
2. Review changes: `terraform plan`
3. Apply changes: `terraform apply`

## 🧹 Cleanup

To destroy all resources:

```bash
terraform destroy
```

**Warning**: This will delete all resources including databases and S3 buckets. Make sure you have backups!

## 📝 Module Documentation

### VPC Module

Creates a complete VPC setup with:

- Public and private subnets
- Internet Gateway
- NAT Gateways (one per AZ)
- Route tables
- VPC Flow Logs

### Security Group Module

Flexible security group creation with:

- Ingress and egress rule management
- Support for CIDR blocks and security group references
- Proper resource tagging

### EC2 Module

EC2 instance with security best practices:

- IMDSv2 enforcement
- Encrypted EBS volumes
- Detailed monitoring option
- Instance termination protection

### ECS Module

Complete ECS Fargate setup:

- ECS cluster with Container Insights
- Task and service definitions
- Auto-scaling configuration
- CloudWatch logging
- IAM roles for task execution and task

### RDS Module

Production-ready RDS PostgreSQL:

- Automated backups
- Multi-AZ option
- Encryption at rest
- Enhanced monitoring
- Performance Insights
- CloudWatch log exports

### S3 Module

Secure S3 bucket:

- Block all public access
- Server-side encryption
- Versioning
- Lifecycle policies
- Access logging support

### SNS Module

Notification system:

- Topic creation
- Subscription management
- CloudWatch alarms for failed deliveries
- Encryption support

### SSM Module

Secure parameter storage:

- KMS encryption for SecureString
- IAM access policy generation
- Organized parameter hierarchy

## 🛠️ Troubleshooting

### Common Issues

1. **Terraform Init Fails**

   - Ensure Terraform version >= 1.5.0
   - Check internet connectivity

2. **Authentication Errors**

   - Configure AWS CLI: `aws configure`
   - Verify IAM permissions

3. **Resource Creation Fails**

   - Check AWS service quotas
   - Verify CIDR block conflicts
   - Ensure unique S3 bucket names

4. **RDS Password Error**
   - Password must be at least 8 characters
   - Cannot contain certain special characters

### Getting Help

Check the [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

## 🔒 Security Notes

1. **Never commit** `terraform.tfvars` or `.tfstate` files to version control
2. Use **AWS Secrets Manager** or **SSM Parameter Store** for production secrets
3. Enable **MFA** for AWS root and IAM users
4. Regularly **rotate credentials** and keys
5. Enable **CloudTrail** for audit logging
6. Review **Security Groups** regularly

## 📈 Cost Optimization

- Use **t3.micro** instances (Free Tier eligible)
- Enable **RDS auto-scaling** for storage
- Implement **S3 lifecycle policies**
- Use **FARGATE_SPOT** for non-critical ECS tasks
- Set up **AWS Budgets** for cost alerts
- Delete unused **NAT Gateways** in dev environments

## 🚀 Production Readiness Checklist

Before deploying to production:

- [ ] Enable Multi-AZ for RDS (`multi_az = true`)
- [ ] Set RDS deletion protection (`deletion_protection = true`)
- [ ] Disable RDS skip final snapshot (`skip_final_snapshot = false`)
- [ ] Configure remote backend (S3 + DynamoDB)
- [ ] Set up proper IAM roles and policies
- [ ] Enable AWS CloudTrail
- [ ] Configure Route53 for DNS
- [ ] Set up Application Load Balancer
- [ ] Enable AWS WAF for ALB
- [ ] Configure proper backup strategies
- [ ] Set up monitoring and alerting
- [ ] Document disaster recovery procedures
- [ ] Restrict security group sources to known IPs
- [ ] Enable AWS Config for compliance

## 📚 Additional Resources

- [Terraform Documentation](https://www.terraform.io/docs)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [AWS Security Best Practices](https://docs.aws.amazon.com/security/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

## 📄 License

This project is licensed under the MIT License.

## 👥 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

---

**Note**: This is a study/learning project. Always review and test thoroughly before using in production environments.
