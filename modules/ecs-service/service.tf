# ---------------------------------------------------
# ecs task_definition and task execution role
# ---------------------------------------------------
data "template_file" "ecs_app" {
  template = file("./modules/ecs-service/templates/task_definition.json.tpl")
  vars = {
    environment        = var.environment
    app_name           = var.app_name
    container_port     = var.container_port
    aws_log_group      = aws_cloudwatch_log_group.ecs_service_log.name
    ecr_url            = data.aws_ecr_repository.service.repository_url
  }
}

resource "aws_ecs_task_definition" "my_first_task" {
  family                   = "${var.prefix_name}"
  container_definitions    = data.template_file.ecs_app.rendered
  requires_compatibilities = ["EC2"]
  network_mode             = "awsvpc"
  memory                   = 256
  cpu                      = 128
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
}

resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "${var.prefix_name}-ecsTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ---------------------------------------------------
# ecs service
# ---------------------------------------------------
resource "aws_ecs_service" "my_first_service" {
  name            = "${var.prefix_name}-service"
  cluster         = var.cluster_name
  task_definition = aws_ecs_task_definition.my_first_task.arn
  launch_type     = "EC2"
  desired_count   = var.container_count

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn
    container_name   = var.app_name // to be confirmed
    container_port   = var.container_port
  }

  network_configuration {
    subnets          = data.aws_subnet_ids.subnet_ids.ids
    security_groups  = [aws_security_group.ecs_service_sg.id] 
  }

  # lifecycle {
  #   create_before_destroy = true
  # }

  depends_on = [ aws_lb_listener.listener ]
}

# ---------------------------------------------------
# Security group for ecs service
# ---------------------------------------------------
resource "aws_security_group" "ecs_service_sg" {
  name_prefix = "${local.prefix}-ecs-service-sg"
  description = "Allow ephemeral port range inbound traffic from tg to ecs"
  vpc_id      = data.aws_vpc.vpc.id

  lifecycle {
    create_before_destroy = true
  }

  revoke_rules_on_delete = true

  tags = merge(
    {
      Name      = "${local.prefix}-ecs-service-sg"
      Component = "Security Group"
    },
    var.tags
  )
}

resource "aws_security_group_rule" "ecs_ingress" {
  type              = "ingress"
  from_port         = 1024
  to_port           = 65535
  protocol          = "tcp"
  # cidr_blocks       = ["10.0.0.0/8", "172.16.0.0/16"]
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ecs_service_sg.id
}

resource "aws_security_group_rule" "ecs_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ecs_service_sg.id
}

# ---------------------------------------------------
# CW log group
# ---------------------------------------------------
resource "aws_cloudwatch_log_group" "ecs_service_log" {
  name = "${local.prefix}-awslog"

  tags = merge(
    {
      Name      = "${local.prefix}-ecs-cw-log"
      Component = "Cloudwatch Log group"
    },
    var.tags
  )
}

# ---------------------------------------------------
# outputs
# ---------------------------------------------------
output "service_url" {
  value = aws_route53_record.alb_record.fqdn 
}