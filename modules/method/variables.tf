variable "rest_api_id" {
  type = string
}

variable "resource_id" {
  type = string
}

variable "methods" {
  type = list(string)
}

variable "lambda_uri" {
  type = string
}

variable "authorization" {
  type    = string
  default = "NONE"
}

variable "api_key_required" {
  type    = bool
  default = false
}
