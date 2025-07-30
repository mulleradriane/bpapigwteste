locals {
  merged_request_params = {
    for m_name, cfg in var.methods : m_name => merge(
      { for p, req in try(cfg.request_parameters.path, {})   : "method.request.path.${p}"        => req },
      { for q, req in try(cfg.request_parameters.query, {})  : "method.request.querystring.${q}" => req },
      { for h, req in try(cfg.request_parameters.header, {}) : "method.request.header.${h}"      => req }
    )
  }

  integration_request_params = {
    for m_name, cfg in var.methods : m_name => merge(
      { for p, req in try(cfg.request_parameters.path, {})   : "integration.request.path.${p}"        => "method.request.path.${p}"        if req },
      { for q, req in try(cfg.request_parameters.query, {})  : "integration.request.querystring.${q}" => "method.request.querystring.${q}" if req },
      { for h, req in try(cfg.request_parameters.header, {}) : "integration.request.header.${h}"      => "method.request.header.${h}"      if req }
    )
  }

  all_responses = merge([
    for method, responses in var.method_responses : {
      for status, cfg in responses :
      "${method} ${status}" => {
        method = method
        status = status
        config = cfg
      }
    }
  ]...)
}

# ---------- Method ----------
resource "aws_api_gateway_method" "this" {
  for_each           = var.methods
  rest_api_id        = var.rest_api_id
  resource_id        = var.resource_id
  http_method        = each.key
  authorization      = var.authorization
  api_key_required   = false
  request_parameters = local.merged_request_params[each.key]
  request_models     = each.value.request_models
  request_validator_id = try(aws_api_gateway_request_validator.this[each.key].id, null)

}

# ---------- Integration ----------
resource "aws_api_gateway_integration" "this" {
  for_each                  = var.methods
  rest_api_id               = var.rest_api_id
  resource_id               = var.resource_id
  http_method               = aws_api_gateway_method.this[each.key].http_method
  type                      = each.value.integration_type
  uri                       = contains(["AWS", "AWS_PROXY", "HTTP", "HTTP_PROXY"], each.value.integration_type) ? each.value.uri : null
  integration_http_method   = contains(["AWS", "AWS_PROXY", "HTTP", "HTTP_PROXY"], each.value.integration_type) ? coalesce(each.value.integration_http_method, "POST") : null
  connection_type           = each.value.integration_type == "VPC_LINK" ? coalesce(each.value.connection_type, "VPC_LINK") : null
  connection_id             = each.value.integration_type == "VPC_LINK" ? each.value.connection_id : null
  passthrough_behavior      = "WHEN_NO_MATCH"
  timeout_milliseconds      = each.value.timeout
  request_parameters        = local.integration_request_params[each.key]
  request_templates         = each.value.request_templates

  depends_on = [aws_api_gateway_method.this]
}

# ---------- Default (sem CORS) ----------
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

# ---------- CORS ----------
resource "aws_api_gateway_method_response" "cors" {
  for_each = {
    for k, v in var.methods :
    k => v
    if v.enable_cors && !contains(keys(try(var.method_responses[k], {})), "200")
  }

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
  for_each = {
    for method_name, method_config in var.methods :
    method_name => method_config
    if method_config.enable_cors &&
       !contains(keys(try(var.method_responses[method_name], {})), "200") &&
       !contains(keys(try(var.integration_response_selection_patterns[method_name], {})), "200")
  }

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

  depends_on = [
    aws_api_gateway_integration.this,
    aws_api_gateway_method_response.cors,
    aws_api_gateway_method_response.custom,
  ]
}




# ---------- Custom Responses ----------
resource "aws_api_gateway_method_response" "custom" {
  for_each = local.all_responses

  rest_api_id         = var.rest_api_id
  resource_id         = var.resource_id
  http_method         = each.value.method
  status_code         = each.value.status
  response_models     = each.value.config.response_models
  response_parameters = each.value.config.response_parameters

  lifecycle {
    ignore_changes = [response_parameters]
  }

  depends_on = [aws_api_gateway_method.this]
}

resource "aws_api_gateway_integration_response" "custom" {
  for_each = {
    for k, v in local.all_responses :
    "${v.method}_${v.status}" => v
    if !(v.status == "200")
  }

  rest_api_id        = var.rest_api_id
  resource_id        = var.resource_id
  http_method        = each.value.method
  status_code        = each.value.status
  response_templates = each.value.config.response_templates
  selection_pattern  = try(each.value.config.selection_pattern, null)

  depends_on = [aws_api_gateway_integration.this]
}



resource "aws_api_gateway_request_validator" "this" {
  for_each    = var.request_validators
  name        = "${each.key}-request-validator"
  rest_api_id = var.rest_api_id

  validate_request_body       = can(regex("body", lower(each.value)))
  validate_request_parameters = can(regex("parameters|query|header", lower(each.value)))

}
