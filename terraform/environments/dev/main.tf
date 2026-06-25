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

  project_name             = var.project_name
  environment              = var.environment
  cluster_id               = module.ecs.cluster_id
  vpc_id                   = module.vpc.vpc_id
  public_subnet_ids        = module.vpc.public_subnet_ids
  private_subnet_ids       = module.vpc.private_subnet_ids
  repository_urls          = module.ecr.repository_urls
  execution_role_arn       = data.aws_iam_role.labrole.arn
  container_port           = 8080
  cpu                      = 256
  memory                   = 512
  desired_count            = 1 //1
  aws_region               = var.aws_region
  vpc_cidr_block           = var.vpc_cidr_block
  autoscaling_services     = ["ui"]
  autoscaling_min_capacity = 1
  autoscaling_max_capacity = 3
  autoscaling_cpu_target   = 70
  service_environment = {

    ui = {
      RETAIL_UI_ENDPOINTS_CATALOG  = "http://${module.ecs_services.catalog_nlb_dns_name}:8080"
      RETAIL_UI_ENDPOINTS_CARTS    = "http://${module.ecs_services.carts_nlb_dns_name}:8080"
      RETAIL_UI_ENDPOINTS_CHECKOUT = "http://${module.ecs_services.checkout_nlb_dns_name}:8080"
      RETAIL_UI_ENDPOINTS_ORDERS   = "http://${module.ecs_services.orders_nlb_dns_name}:8080"
    }

    checkout = {
      RETAIL_CHECKOUT_ENDPOINTS_ORDERS = "http://${module.ecs_services.orders_nlb_dns_name}:8080"
    }

    db = {
      POSTGRES_USER = "retail_user"
      POSTGRES_DB   = "orders"
    }

    catalog = {
      GIN_MODE                            = "release"
      RETAIL_CATALOG_PERSISTENCE_PROVIDER = "postgres"
      RETAIL_CATALOG_PERSISTENCE_ENDPOINT = "${module.ecs_services.db_nlb_dns_name}:5432"
      RETAIL_CATALOG_PERSISTENCE_DB_NAME  = "catalogdb"
      RETAIL_CATALOG_PERSISTENCE_USER     = "retail_user"
    }

    orders = {
      GIN_MODE                           = "release"
      RETAIL_ORDERS_PERSISTENCE_ENDPOINT = "${module.ecs_services.db_nlb_dns_name}:5432"
      RETAIL_ORDERS_PERSISTENCE_NAME     = "orders"
      RETAIL_ORDERS_PERSISTENCE_USERNAME = "retail_user"
    }
  }
  service_secrets = {
    db = {
      POSTGRES_PASSWORD = module.secrets.secret_arns["postgres-password"]
    }

    catalog = {
      RETAIL_CATALOG_PERSISTENCE_PASSWORD = module.secrets.secret_arns["postgres-password"]
    }

    orders = {
      RETAIL_ORDERS_PERSISTENCE_PASSWORD = module.secrets.secret_arns["postgres-password"]
    }
  }
} 