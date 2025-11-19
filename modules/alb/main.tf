# Application Load Balancer
resource "aws_lb" "this" {
  name               = var.alb_name
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = var.security_group_ids
  subnets            = var.subnet_ids

  enable_deletion_protection = var.enable_deletion_protection
  enable_http2               = var.enable_http2
  enable_cross_zone_load_balancing = true

  tags = merge(
    var.tags,
    {
      Name = var.alb_name
    }
  )
}

# Blue Target Group (Production)
resource "aws_lb_target_group" "blue" {
  name        = "${var.alb_name}-prod-tg-2"
  port        = var.target_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = var.target_type

  health_check {
    enabled             = true
    healthy_threshold   = var.health_check_healthy_threshold
    unhealthy_threshold = var.health_check_unhealthy_threshold
    timeout             = var.health_check_timeout
    interval            = var.health_check_interval
    path                = var.health_check_path
    matcher             = var.health_check_matcher
    protocol            = "HTTP"
  }

  deregistration_delay = var.deregistration_delay

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.alb_name}-prod-tg"
      Type = "blue"
    }
  )
}

# Green Target Group (For Blue/Green Deployment)
resource "aws_lb_target_group" "green" {
  name        = "${var.alb_name}-green-tg-2"
  port        = var.target_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = var.target_type

  health_check {
    enabled             = true
    healthy_threshold   = var.health_check_healthy_threshold
    unhealthy_threshold = var.health_check_unhealthy_threshold
    timeout             = var.health_check_timeout
    interval            = var.health_check_interval
    path                = var.health_check_path
    matcher             = var.health_check_matcher
    protocol            = "HTTP"
  }

  deregistration_delay = var.deregistration_delay

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.alb_name}-green-tg"
      Type = "green"
    }
  )
}

# HTTP Listener (Port 80)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = var.enable_https_redirect ? "redirect" : "forward"
    target_group_arn = var.enable_https_redirect ? null : aws_lb_target_group.blue.arn

    dynamic "redirect" {
      for_each = var.enable_https_redirect ? [1] : []
      content {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  }

  tags = var.tags
}

# HTTPS Listener (Port 443) - Optional
resource "aws_lb_listener" "https" {
  count             = var.certificate_arn != null ? 1 : 0
  load_balancer_arn = aws_lb.this.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blue.arn
  }

  tags = var.tags
}

# Test Listener (Port 8080) - For CodeDeploy Blue/Green testing
resource "aws_lb_listener" "test" {
  count             = var.create_test_listener ? 1 : 0
  load_balancer_arn = aws_lb.this.arn
  port              = 8080
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.green.arn
  }

  tags = merge(
    var.tags,
    {
      Name = "test-listener"
    }
  )
}
