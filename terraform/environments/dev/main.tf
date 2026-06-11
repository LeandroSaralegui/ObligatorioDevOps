module "vpc" {
  source = "../../modules/vpc"

  environment    = var.environment
  vpc_name       = var.vpc_name
  vpc_cidr_block = var.vpc_cidr_block

  public_subnets = var.public_subnets

  private_subnets = var.private_subnets

  availability_zones = var.availability_zones
}

module "ecr" {
  source = "../../modules/ecr"

  project_name   = var.project_name
  mircoservicios = var.mircoservicios
  environment    = var.environment
}

module "ecs" {
  source = "../../modules/ecs"

  project_name       = var.project_name
  environment        = var.environment
  log_retention_days = var.log_retention_days
}