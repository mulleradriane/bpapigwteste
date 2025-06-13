locals {
  lambda_methods = [for m in var.methods : m if m != "OPTIONS"]
  mock_methods   = [for m in var.methods : m if m == "OPTIONS"]
}

# Métodos
resource "aws_api_gateway_method" "this" {
  for_each           = toset(var.methods)
  rest_api_id        = var.rest_api_id
  resource_id        = var.resource_id
  http_method        = each.value
  authorization      = var.authorization
  api_key_required   = var.api_key_required
}

# Integração com Lambda (AWS_PROXY)
resource "aws_api_gateway_integration" "this" {
  for_each             = toset(local.lambda_methods)
  rest_api_id          = var.rest_api_id
  resource_id          = var.resource_id
  http_method          = each.value
  integration_http_method = "POST"
  type                 = "AWS_PROXY"
  uri                  = var.lambda_uri
  connection_type      = "INTERNET"
  timeout_milliseconds = 29000

  depends_on = [aws_api_gateway_method.this]
}

# Integração MOCK (para OPTIONS)
resource "aws_api_gateway_integration" "mock" {
  for_each = toset(local.mock_methods)
  rest_api_id = var.rest_api_id
  resource_id = var.resource_id
  http_method = each.value
  type        = "MOCK"
  request_templates = {
    "application/json" = jsonencode({ statusCode = 200 })
  }

  depends_on = [aws_api_gateway_method.this]
}

# Method Response
resource "aws_api_gateway_method_response" "this" {
  for_each           = toset(var.methods)
  rest_api_id        = var.rest_api_id
  resource_id        = var.resource_id
  http_method        = each.value
  status_code        = "200"
  response_models    = { "application/json" = "Empty" }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }

  depends_on = [aws_api_gateway_method.this]
}

# Integration Response para métodos com Lambda
resource "aws_api_gateway_integration_response" "lambda" {
  for_each    = toset(local.lambda_methods)
  rest_api_id = var.rest_api_id
  resource_id = var.resource_id
  http_method = each.value
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  depends_on = [
    aws_api_gateway_method_response.this,
    aws_api_gateway_integration.this
  ]
}

# Integration Response para método OPTIONS (mock)
resource "aws_api_gateway_integration_response" "mock" {
  for_each    = toset(local.mock_methods)
  rest_api_id = var.rest_api_id
  resource_id = var.resource_id
  http_method = each.value
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  depends_on = [
    aws_api_gateway_method_response.this,
    aws_api_gateway_integration.mock
  ]
}
