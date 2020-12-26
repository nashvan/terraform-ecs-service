# ----------------------------------------------------------
# ALB Security Group
# ----------------------------------------------------------
resource "aws_security_group" "alb_sg" {
  name_prefix = "${var.prefix_name}-alb-sg"
  description = "Allow inbound traffic to alb"
  vpc_id      = data.aws_vpc.vpc.id

 lifecycle {
    create_before_destroy = true
  }

  revoke_rules_on_delete = true

  tags = merge(
    {
      Name      = "${local.prefix}-alb-sg"
      Component = "Security Group"
    },
    var.tags
  )
}

resource "aws_security_group_rule" "https_ingress" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["10.0.0.0/8"]
  security_group_id = aws_security_group.alb_sg.id
}

resource "aws_security_group_rule" "http_ingress" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["10.0.0.0/8", "0.0.0.0/0"]
  security_group_id = aws_security_group.alb_sg.id
}

resource "aws_security_group_rule" "alb_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb_sg.id
}

# ----------------------------------------------------------
# ALB
# ----------------------------------------------------------
resource "aws_lb" "alb" {
  name               = "${var.prefix_name}-alb"
  # internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]

  subnets = data.aws_subnet_ids.subnet_ids.ids

  # access_logs {
  #   bucket  = var.alb_access_logs_bucket
  #   prefix  = "${local.prefix}-alb"
  #   enabled = true
  # }

  tags = merge(
    {
      Name      = "${var.prefix_name}-alb"
      Component = "ALB"
    },
    var.tags
  )
}

# ----------------------------------------------------------
# ALB https_listener
# ----------------------------------------------------------
# resource "aws_lb_listener" "alb_https_listener" {
#   load_balancer_arn = aws_lb.alb.arn
#   port              = "80"
#   protocol          = "HTTP"

#   default_action {
#     type = "fixed-response"

#     fixed_response {
#       content_type = "text/plain"
#       message_body = ""
#       status_code  = "404"
#     }
#   }
# }


# resource "aws_lb_listener_rule" "http_listener_rule" {
#   listener_arn = aws_lb_listener.alb_https_listener.arn

#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.target_group.arn # Referencing our tagrte group
#   }

#   condition {
#     host_header {
#       values = ["${aws_route53_record.alb_record.fqdn}"]
#     }
#   }
# }

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn # Referencing our load balancer
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn # Referencing our tagrte group
  }
}
# ----------------------------------------------------------
# ALB target groups
# ----------------------------------------------------------
resource "aws_lb_target_group" "target_group" {
  name        = "${var.prefix_name}-target-group"
  # port        = 3000
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = data.aws_vpc.vpc.id # Referencing the default VPC in our example
  health_check {
    interval            = 40
    healthy_threshold   = 3
    unhealthy_threshold = 2
    # matcher             = "200,301,302"
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    timeout             = var.alb_tg_timeout
  }

  depends_on = [ aws_lb.alb ]
}

# ----------------------------------------------------------
# Route53 record for ALB
# ----------------------------------------------------------
data "aws_route53_zone" "hosted_zone" {
  name         = var.record_set_name
  private_zone = false // depends on your case
}

resource "aws_route53_record" "alb_record" {
  zone_id = data.aws_route53_zone.hosted_zone.zone_id
  name    = "${var.environment}.${var.app_name}"
  type    = "A"

  alias {
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
    evaluate_target_health = false
  }
}

