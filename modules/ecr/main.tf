# ECR Repository
resource "aws_ecr_repository" "this" {
  name                 = var.repository_name
  image_tag_mutability = var.image_tag_mutability

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  encryption_configuration {
    encryption_type = var.encryption_type
    kms_key         = var.kms_key_arn
  }

  tags = merge(
    var.tags,
    {
      Name = var.repository_name
    }
  )
}

# # ECR Lifecycle Policy // (commented due to apply failing on this resource)
# resource "aws_ecr_lifecycle_policy" "this" {
#   count      = length(var.lifecycle_policy) > 0 ? 1 : 0
#   repository = aws_ecr_repository.this.name

#   policy = jsonencode({
#     rules = var.lifecycle_policy
#   })
# }

# ECR Repository Policy (for cross-account access if needed)
resource "aws_ecr_repository_policy" "this" {
  count      = var.repository_policy != null ? 1 : 0
  repository = aws_ecr_repository.this.name
  policy     = var.repository_policy
}
