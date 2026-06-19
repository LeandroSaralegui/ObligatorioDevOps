data "aws_iam_role" "labrole" {
  name = "LabRole"
}

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

module "secrets" {
  source = "../../modules/secrets"

  project_name = var.project_name
  environment  = var.environment

  secrets = [
    "postgres-password",
    "admin-password",
    "admin-jwt-secret"
  ]
}

module "ecs_services" {
  source = "../../modules/ecs_services"

  project_name       = var.project_name
  environment        = var.environment
  cluster_id         = module.ecs.cluster_id
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
  repository_urls    = module.ecr.repository_urls
  execution_role_arn = data.aws_iam_role.labrole.arn
  container_port     = 8080
  cpu                = 256
  memory             = 512
  desired_count      = 0 //1
  aws_region         = var.aws_region
} 