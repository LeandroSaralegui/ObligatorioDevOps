output "alb_dns_name" {
  description = "DNS público del Application Load Balancer"
  value       = aws_lb.this.dns_name
}

output "alb_arn" {
  description = "ARN del Application Load Balancer"
  value       = aws_lb.this.arn
}

output "alb_security_group_id" {
  description = "ID del Security Group del ALB"
  value       = aws_security_group.alb.id
}

output "ecs_tasks_security_group_id" {
  description = "ID del Security Group de ECS Tasks"
  value       = aws_security_group.ecs_tasks.id
}

output "listener_arn" {
  description = "ARN del listener HTTP del ALB"
  value       = aws_lb_listener.http.arn
}

output "target_group_arns" {
  description = "ARNs de los Target Groups por microservicio"
  value = {
    for name, tg in aws_lb_target_group.services :
    name => tg.arn
  }
}

output "task_definition_arns" {
  description = "ARNs de las Task Definitions por microservicio"
  value = {
    for name, task in aws_ecs_task_definition.services :
    name => task.arn
  }
}

output "log_group_names" {
  description = "Nombres de los Log Groups por microservicio"
  value = {
    for name, log_group in aws_cloudwatch_log_group.services :
    name => log_group.name
  }
}

output "ecs_service_names" {
  description = "Nombres de los ECS Services creados"
  value = {
    for name, service in aws_ecs_service.services :
    name => service.name
  }
}

output "db_nlb_dns_name" {
  value = aws_lb.db.dns_name
}

output "catalog_nlb_dns_name" {
  value = aws_lb.catalog.dns_name
}

output "orders_nlb_dns_name" {
  value = aws_lb.orders.dns_name
}

output "checkout_nlb_dns_name" {
  value = aws_lb.checkout.dns_name
}

output "carts_nlb_dns_name" {
  value = aws_lb.carts.dns_name
}

output "alb_arn_suffix" {
  description = "ARN suffix del ALB público"
  value       = aws_lb.this.arn_suffix
}

output "ui_target_group_arn_suffix" {
  description = "ARN suffix del Target Group de UI"
  value       = aws_lb_target_group.services["ui"].arn_suffix
}

output "ui_service_name" {
  description = "Nombre del ECS Service de UI"
  value       = aws_ecs_service.services["ui"].name
}