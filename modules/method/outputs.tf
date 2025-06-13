# Métodos (GET, POST, PUT, OPTIONS, etc.)
output "methods" {
  value = [for m in aws_api_gateway_method.this : {
    http_method = m.http_method
    resource_id = m.resource_id
  }]
}

output "method_configs" {
  value = [for m in aws_api_gateway_method.this : {
    http_method = m.http_method
    resource_id = m.resource_id
  }]
}

output "method_ids" {
  value = aws_api_gateway_method.this
}

output "method_resources" {
  value = [for m in aws_api_gateway_method.this : m.id]
}

# Integrações por tipo (lambda e mock)
output "integrations_lambda" {
  value = aws_api_gateway_integration.lambda
}

output "integrations_mock" {
  value = aws_api_gateway_integration.mock
}
