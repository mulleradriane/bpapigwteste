output "integrations" {
  value = [for integration in aws_api_gateway_integration.this : integration]
}

output "method_ids" {
  value = aws_api_gateway_method.this
}

output "integration_ids" {
  value = aws_api_gateway_integration.this
}

output "method_resources" {
  value = [for m in aws_api_gateway_method.this : m.id]
}

output "integration_resources" {
  value = aws_api_gateway_integration.this
}

output "methods" {
  value = [for m in aws_api_gateway_method.this : {
    http_method = m.http_method
    resource_id = m.resource_id
  }]
}
