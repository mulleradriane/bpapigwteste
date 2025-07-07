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
    connection_type           = optional(string)
    connection_id             = optional(string)
    proxy                     = optional(bool, false)
    timeout                   = optional(number, 29000)
    request_parameters        = optional(map(string), {})
    request_models            = optional(map(string), {})
    request_templates         = optional(map(string), {})
    enable_cors               = optional(bool, false)
  }))
}


# CORS configuráveis
variable "cors_allow_headers" {
  type        = string
  default     = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
}

variable "cors_allow_methods" {
  type        = string
  default     = "'GET,POST,PUT,DELETE,OPTIONS'"
}

variable "cors_allow_origin" {
  type        = string
  default     = "'*'"
}

