data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "${path.module}/lambda_observability_status.zip"

  source {
    filename = "index.js"
    content  = <<EOF
exports.handler = async (event) => {
  console.log("Evento recibido:", JSON.stringify(event));

  return {
    statusCode: 200,
    headers: {
      "Content-Type": "application/json",
      "Access-Control-Allow-Origin": "*"
    },
    body: JSON.stringify({
      service: "retailstore-observability-status",
      environment: process.env.ENVIRONMENT,
      status: "ok",
      purpose: "serverless observability endpoint",
      architecture: "api-gateway-http-api-lambda",
      timestamp: new Date().toISOString()
    })
  };
};
EOF
  }
}

resource "aws_lambda_function" "observability_status" {
  function_name    = "${var.project_name}-${var.environment}-observability-status"
  role             = var.lambda_role_arn
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  timeout          = 3
  memory_size      = 128

  environment {
    variables = {
      ENVIRONMENT = var.environment
    }
  }
}

resource "aws_apigatewayv2_api" "http_api" {
  name          = "${var.project_name}-${var.environment}-observability-api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET"]
    allow_headers = ["content-type"]
  }
}

resource "aws_apigatewayv2_integration" "lambda" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.observability_status.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "observability_status" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /observability/status"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true

  default_route_settings {
    throttling_rate_limit  = 100
    throttling_burst_limit = 200
  }
}

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.observability_status.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*"
}