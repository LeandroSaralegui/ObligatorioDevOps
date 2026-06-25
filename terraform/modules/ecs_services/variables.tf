variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
}

variable "environment" {
  description = "Ambiente de despliegue"
  type        = string
}

variable "cluster_id" {
  description = "ID del cluster ECS"
  type        = string
}

variable "vpc_id" {
  description = "ID de la VPC"
  type        = string
}

variable "public_subnet_ids" {
  description = "Subnets públicas para el ALB"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "Subnets privadas para las tareas ECS"
  type        = list(string)
}

variable "repository_urls" {
  description = "URLs de los repositorios ECR por microservicio"
  type        = map(string)
}

variable "execution_role_arn" {
  description = "ARN del rol IAM usado por ECS para ejecutar tareas"
  type        = string
}

variable "container_port" {
  description = "Puerto expuesto por los contenedores"
  type        = number
  default     = 8080
}

variable "cpu" {
  description = "CPU para cada tarea Fargate"
  type        = number
  default     = 256
}

variable "memory" {
  description = "Memoria para cada tarea Fargate"
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Cantidad deseada de tareas por servicio"
  type        = number
  default     = 1
}

variable "aws_region" {
  description = "Región AWS"
  type        = string
}

variable "public_services" {
  description = "Microservicios expuestos públicamente por el ALB"
  type        = set(string)
  default     = ["ui", "admin"]
}

variable "service_environment" {
  description = "Variables de entorno por servicio ECS"
  type        = map(map(string))
  default     = {}
}

variable "service_secrets" {
  description = "Secrets de AWS Secrets Manager por servicio ECS"
  type        = map(map(string))
  default     = {}
}

variable "vpc_cidr_block" {
  description = "CIDR block de la VPC"
  type        = string
}

variable "autoscaling_services" {
  description = "Microservicios con Auto Scaling habilitado"
  type        = set(string)
}

variable "autoscaling_min_capacity" {
  description = "Cantidad mínima de tareas por servicio"
  type        = number
  default     = 1
}

variable "autoscaling_max_capacity" {
  description = "Cantidad máxima de tareas por servicio"
  type        = number
  default     = 3
}

variable "autoscaling_cpu_target" {
  description = "Porcentaje objetivo de utilización de CPU para el Auto Scaling"
  type        = number
  default     = 70
}