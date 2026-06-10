variable "mircoservicios" {
  description = "Lista de microservicios para crear repositorio ECR"
  type = list(string)
}

variable "project_name" {
  description = "Nombre del proyecto"
  type = string
}

variable "environment" {
    description = "Ambiente de despliegue"
    type = string
}