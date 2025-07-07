output "method_ids" {
  value = {
    for k, m in aws_api_gateway_method.this :
    k => m.id
  }
}
