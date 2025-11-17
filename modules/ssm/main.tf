# SSM Parameters
resource "aws_ssm_parameter" "main" {
  for_each = var.parameters

  name        = each.value.name
  description = lookup(each.value, "description", null)
  type        = lookup(each.value, "type", "String")
  value       = each.value.value
  tier        = lookup(each.value, "tier", "Standard")
  key_id      = lookup(each.value, "type", "String") == "SecureString" ? var.kms_key_id : null

  overwrite   = lookup(each.value, "overwrite", true)
  
  tags = merge(
    var.tags,
    lookup(each.value, "tags", {}),
    {
      Name = each.value.name
    }
  )
}

# KMS Key for SSM (Best Practice)
resource "aws_kms_key" "ssm" {
  count               = var.create_kms_key ? 1 : 0
  description         = "KMS key for SSM Parameter Store encryption"
  enable_key_rotation = true

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-ssm-kms"
    }
  )
}

resource "aws_kms_alias" "ssm" {
  count         = var.create_kms_key ? 1 : 0
  name          = "alias/${var.project_name}-ssm"
  target_key_id = aws_kms_key.ssm[0].key_id
}

# IAM Policy for SSM Parameter Access
resource "aws_iam_policy" "ssm_access" {
  count       = var.create_access_policy ? 1 : 0
  name        = "${var.project_name}-ssm-access-policy"
  description = "Policy for accessing SSM parameters"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath"
        ]
        Resource = [
          for param in aws_ssm_parameter.main : param.arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt"
        ]
        Resource = var.create_kms_key ? [aws_kms_key.ssm[0].arn] : [var.kms_key_id]
      }
    ]
  })

  tags = var.tags
}
