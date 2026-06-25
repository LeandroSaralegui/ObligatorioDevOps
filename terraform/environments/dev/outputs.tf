output "vpc_id" {
  description = "ID de la VPC creada para el ambiente"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs de las subnets públicas creadas"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs de las subnets privadas creadas"
  value       = module.vpc.private_subnet_ids
}

output "ecr_repository_urls" {
  description = "URLs de los repositorios ECR creados para los microservicios"
  value       = module.ecr.repository_urls
}

output "ecs_cluster_name" {
  description = "Nombre del cluster ECS creado"
  value       = module.ecs.cluster_name
}

output "ecs_cluster_arn" {
  description = "ARN del cluster ECS creado"
  value       = module.ecs.cluster_arn
}

output "ecs_log_group_name" {
  description = "Nombre del CloudWatch Log Group asociado a ECS"
  value       = module.ecs.log_group_name
}

output "observability_status_url" {
  description = "Endpoint serverless de observabilidad"
  value       = module.serverless.observability_status_url
}