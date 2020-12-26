[
  {
    "name": "${app_name}",
    "image": "${ecr_url}",
    "cpu": 128,
    "memory": 256,
    "essential": true,
    "portMappings": [
      {
        "containerPort": ${container_port},
        "hostPort": ${container_port} 
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region": "us-east-1",
        "awslogs-stream-prefix": "${app_name}-${environment}-service",
        "awslogs-group": "${aws_log_group}"
      }
    }
  }
]