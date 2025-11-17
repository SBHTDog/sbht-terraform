resource "aws_instance" "main" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  
  vpc_security_group_ids = var.security_group_ids
  
  iam_instance_profile = var.iam_instance_profile
  key_name             = var.key_name
  
  user_data                   = var.user_data
  user_data_replace_on_change = var.user_data_replace_on_change

  root_block_device {
    volume_type           = var.root_volume_type
    volume_size           = var.root_volume_size
    delete_on_termination = var.root_delete_on_termination
    encrypted             = var.root_volume_encrypted
    kms_key_id            = var.root_volume_kms_key_id
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = var.metadata_http_tokens
    http_put_response_hop_limit = var.metadata_http_put_response_hop_limit
    instance_metadata_tags      = "enabled"
  }

  monitoring                 = var.enable_detailed_monitoring
  disable_api_termination    = var.disable_api_termination
  disable_api_stop           = var.disable_api_stop
  
  tags = merge(
    var.tags,
    {
      Name = var.instance_name
    }
  )

  volume_tags = merge(
    var.tags,
    {
      Name = "${var.instance_name}-volume"
    }
  )

  lifecycle {
    ignore_changes = [ami]
  }
}