variable "aws_region" {
  description = "Región de AWS"
  type        = string
}
variable "environment" {
  description = "Enviroment en donde se esta ejecutando el IaC"
  type        = string
}

variable "vpc_cidr_block" {
  description = "CIDR del VPC"
  type        = string
}

variable "vpc_name" {
  description = "Nombre del VPC"
  type        = string
}

variable "public_subnets" {
  description = "Lista de Subnets publicas"
  type        = list(string)
}

variable "private_subnets" {
  description = "Lista de Subnets privadas"
  type        = list(string)
}

variable "availability_zones" {
  description = "Zonas Disponibles"
  type        = list(string)
}

variable "mircoservicios" {
  description = "Lista de microservicios para crear repositorio ECR"
  type        = list(string)
}

variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
}

variable "log_retention_days" {
  description = "Cantidad de días de retención de logs en CloudWatch"
  type        = number
  default     = 7
}