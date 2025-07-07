resource "aws_api_gateway_method" "this" {
  for_each           = var.methods
  rest_api_id        = var.rest_api_id
  resource_id        = var.resource_id
  http_method        = each.key
  authorization      = var.authorization
  api_key_required   = false
  request_parameters = each.value.request_parameters
  request_models     = each.value.request_models
}

resource "aws_api_gateway_integration" "this" {
  for_each            = var.methods
  rest_api_id         = var.rest_api_id
  resource_id         = var.resource_id
  http_method         = aws_api_gateway_method.this[each.key].http_method
  type                = each.value.integration_type

  uri                       = contains(["AWS", "AWS_PROXY", "HTTP", "HTTP_PROXY"], each.value.integration_type) ? each.value.uri : null
  integration_http_method   = contains(["AWS", "AWS_PROXY", "HTTP", "HTTP_PROXY"], each.value.integration_type) ? coalesce(each.value.integration_http_method, "POST") : null
  connection_type           = each.value.integration_type == "VPC_LINK" ? coalesce(each.value.connection_type, "VPC_LINK") : null
  connection_id             = each.value.integration_type == "VPC_LINK" ? each.value.connection_id : null
  passthrough_behavior      = "WHEN_NO_MATCH"
  timeout_milliseconds      = each.value.timeout

  request_parameters        = each.value.request_parameters
  request_templates         = each.value.request_templates

  depends_on = [aws_api_gateway_method.this]
}


# Default (sem CORS)
resource "aws_api_gateway_method_response" "default" {
  for_each    = { for k, v in var.methods : k => v if !v.enable_cors }
  rest_api_id = var.rest_api_id
  resource_id = var.resource_id
  http_method = each.key
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  lifecycle {
    ignore_changes = [response_parameters]
  }

  depends_on = [aws_api_gateway_method.this]
}

resource "aws_api_gateway_integration_response" "default" {
  for_each    = { for k, v in var.methods : k => v if !v.enable_cors }
  rest_api_id = var.rest_api_id
  resource_id = var.resource_id
  http_method = each.key
  status_code = "200"

  response_templates = {
    "application/json" = ""
  }

  depends_on = [aws_api_gateway_integration.this]
}

# CORS
resource "aws_api_gateway_method_response" "cors" {
  for_each    = { for k, v in var.methods : k => v if v.enable_cors }
  rest_api_id = var.rest_api_id
  resource_id = var.resource_id
  http_method = each.key
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }

  response_models = {
    "application/json" = "Empty"
  }

  lifecycle {
    ignore_changes = [response_parameters]
  }

  depends_on = [aws_api_gateway_method.this]
}

resource "aws_api_gateway_integration_response" "cors" {
  for_each    = { for k, v in var.methods : k => v if v.enable_cors }
  rest_api_id = var.rest_api_id
  resource_id = var.resource_id
  http_method = each.key
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = var.cors_allow_headers
    "method.response.header.Access-Control-Allow-Methods" = var.cors_allow_methods
    "method.response.header.Access-Control-Allow-Origin"  = var.cors_allow_origin
  }

  response_templates = {
    "application/json" = ""
  }

  depends_on = [aws_api_gateway_integration.this]
}
