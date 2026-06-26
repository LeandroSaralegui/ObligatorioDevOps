aws_region = "us-east-1"

environment = "dev"

vpc_cidr_block = "10.10.0.0/16"

vpc_name = "dev-vpc"

public_subnets = [
  "10.10.1.0/24",
  "10.10.2.0/24"
]

private_subnets = [
  "10.10.11.0/24",
  "10.10.12.0/24"
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
