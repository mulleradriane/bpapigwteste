output "deployment_id" {
  value = aws_api_gateway_deployment.this.id
}

output "invoke_url" {
  value = aws_api_gateway_deployment.this.invoke_url
}
