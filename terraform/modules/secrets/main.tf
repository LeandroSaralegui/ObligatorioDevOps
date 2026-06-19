resource "aws_secretsmanager_secret" "this" {
  for_each = toset(var.secrets)

  name        = "${var.project_name}/${var.environment}/${each.value}"
  description = "Secret ${each.value} para ${var.project_name} en ambiente ${var.environment}"

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}