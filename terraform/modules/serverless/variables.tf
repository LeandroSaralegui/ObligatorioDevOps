variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
}

variable "environment" {
  description = "Ambiente de despliegue"
  type        = string
}

variable "aws_region" {
  description = "Región AWS"
  type        = string
}

variable "lambda_role_arn" {
  description = "ARN del rol IAM existente para ejecutar Lambda"
  type        = string
}