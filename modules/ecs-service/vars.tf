variable "prefix_name" {
  type        = string
  description = "the prefix name for the resources"
}

variable "cost_centre" {
  type        = string
  description = "Project cost centre tag value"
}

variable "application_id" {
  type        = string
  description = "Application ID tag value"
}

variable "service_name" {
  type        = string
  description = "Service name used to namespace the resources created in AWS"
  default     = "nabx"
}

variable "app_name" {
  type        = string
  description = "Application name used to namespace the resources created in AWS"
  default     = "example"
}

variable "environment" {
  type        = string
  description = "Environment name for namespacing the resources created in AWS"
  default     = "develop"
}

variable "owner" {
  default     = "Nash Support"
  type        = string
  description = "The resource owner to tag all the resources with"
}


variable "tags" {
  description = "A map of tags to assign to resources."
  type        = map(string)
  default     = {}
}

variable "record_set_name" {
  type        = string
  description = "Name of the zone that will be used by the Route 53 record of the cluster's ALB"
}

variable "cluster_name" {
  type        = string
  description = "Name of the ecs cluster to host this ecs service"
}


variable "minimum_healthy_percent_service" {
  default     = 100
  description = "ECS minimum_healthy_percent configuration, set it lower than 100 to allow rolling update without adding new instances"
}

variable "alb_tg_healthy_threshold" {
  description = "ALB Target Group Healthy Threshold"
  default     = 3
}

variable "alb_tg_unhealthy_threshold" {
  description = "ALB Target Group Unhealthy Threshold"
  default     = 2
}

variable "interval" {
  description = "ALB Target Group Timeout"
  default     = 30
}

variable "alb_tg_timeout" {
  description = "ALB Target Group Timeout"
  default     = 5
}

variable "protocol" {
  type        = string
  description = "name of the ptotocol used by ALB and target group"
  default     = "HTTPS"
}

variable "alb_traffic_port" {
  description = "The port to expose the service on the ALB"
  default     = 443
}

variable "container_port" {
  type        = string
  description = "The port that the ALB must route traffic to the container"
  default     = 443
}

# variable "container_name" {
#   type        = string
#   description = "The name (as it appears in the container definition) of the container to direct traffic to"
# }

variable "container_count" {
  type        = string
  default     = 1
  description = "Number of container tasks to run"
}

variable "health_check_path" {
  type        = string
  default     = "/"
  description = "The health check path used by the target group"
}
