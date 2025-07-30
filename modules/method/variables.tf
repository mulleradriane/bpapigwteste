variable "rest_api_id" {
  type = string
}

variable "resource_id" {
  type = string
}

variable "authorization" {
  type    = string
  default = "NONE"
}

variable "methods" {
  type = map(object({
    integration_type          = string
    uri                       = optional(string)
    integration_http_method   = optional(string)
    proxy                     = optional(bool, false)
    connection_type           = optional(string)
    connection_id             = optional(string)
    timeout                   = optional(number, 29000)
    request_parameters = optional(object({
      path   = map(bool)
      query  = map(bool)
      header = map(bool)
    }), {
      path   = {}
      query  = {}
      header = {}
    })
    request_templates = optional(map(string), {})
    request_models    = optional(map(string), {})
    enable_cors       = optional(bool, false)
  }))
}

variable "method_responses" {
  description = "Responses customizadas por método"
  type = map(map(object({
    response_models     = optional(map(string), {})
    response_templates  = optional(map(string), {})
    response_parameters = optional(map(string), {})
    selection_pattern   = optional(string)
  })))
  default = {}
}


# CORS configuráveis
variable "cors_allow_headers" {
  type    = string
  default = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
}

variable "cors_allow_methods" {
  type    = string
  default = "'GET,POST,PUT,DELETE,OPTIONS'"
}

variable "cors_allow_origin" {
  type    = string
  default = "'*'"
}

variable "request_validators" {
  description = "Mapa de validadores por método"
  type = map(string)
  default = {}
}

variable "integration_response_selection_patterns" {
  description = "Mapeia selection_pattern para integration_response por método e status code"
  type = map(map(string))
  default = {}
}
