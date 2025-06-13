resource "aws_api_gateway_method" "this" {
  for_each           = toset(var.methods)
  rest_api_id        = var.rest_api_id
  resource_id        = var.resource_id
  http_method        = each.key
  authorization      = "NONE"
  api_key_required   = false
  request_parameters = {}
}

resource "aws_api_gateway_integration" "lambda" {
  for_each                = { for m in var.methods : m => m if m != "OPTIONS" }
  rest_api_id             = var.rest_api_id
  resource_id             = var.resource_id
  http_method             = each.key
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_uri
  connection_type         = "INTERNET"
  timeout_milliseconds    = 29000
}

resource "aws_api_gateway_integration" "mock" {
  for_each             = { for m in var.methods : m => m if m == "OPTIONS" }
  rest_api_id          = var.rest_api_id
  resource_id          = var.resource_id
  http_method          = each.key
  type                 = "MOCK"
  connection_type      = "INTERNET"
  timeout_milliseconds = 29000

  request_templates = {
    "application/json" = jsonencode({ statusCode = 200 })
  }
}

resource "aws_api_gateway_method_response" "this" {
  for_each = toset(var.methods)

  rest_api_id = var.rest_api_id
  resource_id = var.resource_id
  http_method = each.key
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "lambda" {
  for_each = { for m in var.methods : m => m if m != "OPTIONS" }

  rest_api_id = var.rest_api_id
  resource_id = var.resource_id
  http_method = each.key
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
  depends_on = [aws_api_gateway_method_response.this]
}

resource "aws_api_gateway_integration_response" "mock" {
  for_each = { for m in var.methods : m => m if m == "OPTIONS" }

  rest_api_id = var.rest_api_id
  resource_id = var.resource_id
  http_method = each.key
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
  depends_on = [aws_api_gateway_method_response.this]
}
