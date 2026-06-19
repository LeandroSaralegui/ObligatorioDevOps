variable "project_name" {
  type        = string
  description = "Nombre del proyecto"
}

variable "environment" {
  type        = string
  description = "Ambiente"
}

variable "secrets" {
  type        = list(string)
  description = "Lista de secretos a crear"
}