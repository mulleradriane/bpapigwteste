resource "aws_api_gateway_deployment" "this" {
  rest_api_id = var.rest_api_id

  triggers = {
    redeploy = var.triggers_sha
  }

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_api_gateway_stage" "this" {
  deployment_id = aws_api_gateway_deployment.this.id
  rest_api_id   = var.rest_api_id
  stage_name    = var.stage_name
}
