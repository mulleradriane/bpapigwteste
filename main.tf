provider "aws" {
  region = "us-east-1"
}

module "api" {
  source      = "./modules/api"
  name        = "meu-projeto-api"
  description = "API de exemplo com blueprint"
  stage_name  = "dev"
}

module "hello_resource" {
  source      = "./modules/resource"
  rest_api_id = module.api.id
  parent_id   = module.api.root_resource_id
  path_part   = "hello"
}

module "lambda_hello" {
  source        = "./modules/lambda"
  function_name = "hello-lambda"
  runtime       = "nodejs18.x"
  handler       = "index.handler"
  filename      = "${path.module}/hello.zip"
}

module "hello_methods" {
  source        = "./modules/method"
  rest_api_id   = module.api.id
  resource_id   = module.hello_resource.id
  lambda_uri    = module.lambda_hello.uri
  authorization = "NONE"
  methods       = ["GET", "POST", "OPTIONS", "PUT"]
}


resource "null_resource" "wait_for_methods" {
  depends_on = [
    module.hello_methods
  ]
}


locals {
  method_configs = flatten([
    for method in module.hello_methods.method_configs : {
      http_method = method.http_method
      resource_id = method.resource_id
    }
  ])
}


module "deployment" {
  source         = "./modules/deployment"
  rest_api_id    = module.api.id
  stage_name     = "dev"
  method_configs = local.method_configs

}
