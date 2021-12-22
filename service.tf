module "ecs-service" {
  source = "./modules/ecs-service"

  environment     = var.environment
  app_name        = local.app_name
  application_id  = local.application_id
  cost_centre     = local.cost_centre
  service_name    = local.service_name

  container_count = 1
  container_port  = 80
  record_set_name = local.account_config["record_set_name"]
  cluster_name    = "xyz-abc-${var.environment}-ecs-cluster"
  prefix_name     = "${local.service_name}-${local.app_name}-${var.environment}"
  
  # Optionally you can have EFS volume attached to the ECS if needed as below
  #volumes = [
  #  {
  #    name      = "static_html"
  #    file_system_id = aws_efs_file_system.fs.id
  #    root_directory = 
  #    access_point = refere to access point

  #  },
  #  {
  #    name      = "static_html"
  #    file_system_id = aws_efs_file_system.fs.id
  #    root_directory = 
  #    access_point = refere to access point

  #  }
  #]

  tags = {
    ApplicationID = local.application_id
    CostCentre    = local.cost_centre
    ServiceName   = local.service_name
    Environment   = var.environment
  }
}

output "service_url" {
  value = module.ecs-service.service_url
}
