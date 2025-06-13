variable "rest_api_id" {
  type        = string
  description = "ID da REST API"
}

variable "stage_name" {
  type        = string
  description = "Nome do stage da API"
}

variable "method_configs" {
  type = list(object({
    http_method = string
    resource_id = string
  }))
  description = "Lista de métodos e recursos para cálculo de hash e trigger do deployment"
}
