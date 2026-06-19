output "secret_arns" {
  description = "ARNs de los secretos creados en AWS Secrets Manager"
  value = {
    for name, secret in aws_secretsmanager_secret.this :
    name => secret.arn
  }
}

output "secret_names" {
  description = "Nombres de los secretos creados en AWS Secrets Manager"
  value = {
    for name, secret in aws_secretsmanager_secret.this :
    name => secret.name
  }
}