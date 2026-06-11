variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
}

variable "environment" {
  description = "Ambiente de despliegue"
  type        = string
}

variable "log_retention_days" {
  description = "Cantidad de días de retención de logs en CloudWatch"
  type        = number
  default     = 7
}