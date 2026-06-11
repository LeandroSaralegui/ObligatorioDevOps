output "cluster_id" {
  description = "ID del cluster ECS creado"
  value       = aws_ecs_cluster.main.id
}

output "cluster_name" {
  description = "Nombre del cluster ECS creado"
  value       = aws_ecs_cluster.main.name
}

output "cluster_arn" {
  description = "ARN del cluster ECS creado"
  value       = aws_ecs_cluster.main.arn
}

output "log_group_name" {
  description = "Nombre del CloudWatch Log Group usado por ECS"
  value       = aws_cloudwatch_log_group.ecs.name
}

output "log_group_arn" {
  description = "ARN del CloudWatch Log Group usado por ECS"
  value       = aws_cloudwatch_log_group.ecs.arn
}