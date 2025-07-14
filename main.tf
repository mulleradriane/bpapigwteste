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
      integration_type = "AWS_PROXY"

      uri                     = module.lambda_hello.uri
      integration_http_method = "POST"
      proxy                   = true
      enable_cors             = false
    },
    "OPTIONS" = {
      integration_type = "MOCK"
      enable_cors      = true
    },
    "POST" = {
      integration_type        = "HTTP"
      uri                     = "https://httpbin.org/post"
      integration_http_method = "POST"
      enable_cors             = true
    }
  }

  cors_allow_methods = "'GET,POST,OPTIONS'"
  cors_allow_origin  = "'*'"
  cors_allow_headers = "'Authorization,Content-Type'"
}

module "item_resource" {
  source      = "./modules/resource"
  rest_api_id = module.api.id
  parent_id   = module.api.root_resource_id
  path_part   = "items"
}

module "item_id_resource" {
  source      = "./modules/resource"
  rest_api_id = module.api.id
  parent_id   = module.item_resource.id
  path_part   = "{id}" # ← path param
}

module "item_methods" {
  source        = "./modules/method"
  rest_api_id   = module.api.id
  resource_id   = module.item_id_resource.id
  authorization = "NONE"

  methods = {
    "GET" = {
      integration_type        = "HTTP"
      uri                     = "https://httpbin.org/anything"
      integration_http_method = "GET"
      enable_cors             = true

      request_parameters = {
        path   = { id = true } # obrigatório /items/{id}
        query  = { sort = false }
        header = { Authorization = true }
      }

      request_templates = {
        "application/json" = <<EOF
{
  "requestedId": "$input.params('id')",
  "sort": "$input.params('sort')"
}
EOF
      }
    },
    "OPTIONS" = {
      integration_type = "MOCK"
      enable_cors      = true
    }
  }

  method_responses = {
    GET = {
      "404" = {
        response_models = {
          "application/json" = "Empty"
        }
        response_templates = {
          "application/json" = jsonencode({
            message = "Item not found",
            code    = 404
          })
        }
        response_parameters = {
          "method.response.header.Content-Type" = true
        }
      }
    }
  }

  cors_allow_methods = "'GET,OPTIONS'"
  cors_allow_origin  = "'https://frontend.acme.com'"
  cors_allow_headers = "'Authorization,Content-Type'"
}
