aws_region = "us-east-1"

environment = "test"

vpc_cidr_block = "10.20.0.0/16"

vpc_name = "test-vpc"

public_subnets = [
  "10.20.1.0/24",
  "10.20.2.0/24"
]

private_subnets = [
  "10.20.11.0/24",
  "10.20.12.0/24"
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