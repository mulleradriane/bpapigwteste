provider "aws" {
  region = "us-east-1"
}

##############################
# API Gateway REST API
##############################
module "api" {
  source      = "./modules/api"
  name        = "meu-projeto-apiv2"
  description = "API de exemplo com blueprint"
  stage_name  = "dev"
}

##############################
# Recurso: /hello
##############################
module "hello_resource" {
  source      = "./modules/resource"
  rest_api_id = module.api.id
  parent_id   = module.api.root_resource_id
  path_part   = "hello"
}

##############################
# Lambda Function: Hello
##############################
module "lambda_hello" {
  source        = "./modules/lambda"
  function_name = "hello-lambdav2"
  runtime       = "nodejs18.x"
  handler       = "index.handler"
  filename      = "${path.module}/hello.zip"
}

module "hello_methods" {
  source        = "./modules/method"
  rest_api_id   = module.api.id
  resource_id   = module.hello_resource.id
  authorization = "NONE"

  methods = {
    "GET" = {
      integration_type          = "AWS_PROXY"
      uri                       = module.lambda_hello.uri
      integration_http_method   = "POST"
      proxy                     = true
      enable_cors               = false
    },
    "OPTIONS" = {
      integration_type = "MOCK"
      enable_cors      = true
    },
    "POST" = {
      integration_type          = "HTTP"
      uri                       = "https://httpbin.org/post"
      integration_http_method   = "POST"
      enable_cors               = true
    }
  }

  cors_allow_methods = "'GET,POST,OPTIONS'"
  cors_allow_origin  = "'*'"
  cors_allow_headers = "'Authorization,Content-Type'"
}

