aws_region = "us-east-1"

environment = "prod"

vpc_cidr_block = "10.30.0.0/16"

vpc_name = "prod-vpc"

public_subnets = [
  "10.30.1.0/24",
  "10.30.2.0/24"
]

private_subnets = [
  "10.30.11.0/24",
  "10.30.12.0/24"
]

availability_zones = [
  "us-east-1a",
  "us-east-1b"
]

project_name = "retailstore"

mircoservicios = [
  "admin",
  "ui",
  "carts",
  "catalog",
  "checkout",
  "orders",
  "db"
]

log_retention_days = 7

ecr_registry = "884569638745.dkr.ecr.us-east-1.amazonaws.com"