output "api_endpoint" {
  description = "URL base de la HTTP API"
  value       = aws_apigatewayv2_api.http_api.api_endpoint
}

output "observability_status_url" {
  description = "Endpoint serverless de observabilidad"
  value       = "${aws_apigatewayv2_api.http_api.api_endpoint}/observability/status"
}

output "lambda_name" {
  description = "Nombre de la función Lambda"
  value       = aws_lambda_function.observability_status.function_name
}