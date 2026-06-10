output "repository_urls" {
  description = "URLs de los repositorios ECR creados"
  value = {
    for name, repo in aws_ecr_repository.microservicios :
    name => repo.repository_url
  }
}

output "repository_arns" {
  description = "ARNs de los repositorios ECR creados"
  value = {
    for name, repo in aws_ecr_repository.microservicios :
    name => repo.arn
  }
}