# API Gateway com Terraform – Blueprint

Este projeto configura uma REST API da AWS utilizando módulos Terraform altamente reutilizáveis. A arquitetura inclui:

- AWS API Gateway (REST)
- Lambda Functions
- Integrações por método (Lambda, Mock)
- CORS configurado automaticamente
- Deploy controlado por `sha1` para evitar ciclos e `null_resource`

## 🧱 Estrutura
├── main.tf
├── modules/
│ ├── api/
│ ├── resource/
│ ├── method/
│ ├── lambda/
│ └── deployment/


## ✅ Funcionalidades já implementadas

- [x] Criação de REST API (`aws_api_gateway_rest_api`)
- [x] Recurso `/hello` com métodos GET, POST, PUT, OPTIONS
- [x] Integração com função Lambda
- [x] Integração mock (CORS)
- [x] CORS Headers automáticos para todos os métodos
- [x] Deployment com hash de métodos via `sha1(jsonencode(...))`
- [x] Modularização total com variáveis e outputs

## 📌 O que ainda pode ser implementado

- [ ] Métodos adicionais: DELETE, PATCH, HEAD, ANY
- [ ] API Key + usage plan (proteção por chave)
- [ ] Autenticação por IAM, Cognito ou Custom Authorizer
- [ ] Validação de parâmetros no método
- [ ] Logging de execução do API Gateway
- [ ] Integrações alternativas: HTTP, VPC Link, AWS Service
- [ ] Proxy resource (`/{proxy+}`)
- [ ] Testes automatizados (Terratest ou InSpec)





##### MODULOS!



# Módulo Terraform: API Gateway Method

Este módulo cria métodos HTTP para um recurso de API Gateway REST, integrando-os a uma função Lambda e configurando CORS automaticamente.

## Recursos Criados

- `aws_api_gateway_method`
- `aws_api_gateway_integration` (Lambda ou MOCK para OPTIONS)
- `aws_api_gateway_method_response`
- `aws_api_gateway_integration_response`

## Variáveis de Entrada

| Nome              | Tipo            | Descrição                                                                 | Obrigatório |
|-------------------|------------------|---------------------------------------------------------------------------|-------------|
| `rest_api_id`     | `string`         | ID da API Gateway REST                                                    | Sim         |
| `resource_id`     | `string`         | ID do recurso (resource) da API Gateway                                   | Sim         |
| `lambda_uri`      | `string`         | URI da função Lambda para integração (opcional para métodos MOCK/OPTIONS) | Sim         |
| `authorization`   | `string`         | Tipo de autorização (ex: `NONE`, `AWS_IAM`)                               | Sim         |
| `methods`         | `list(string)`   | Lista de métodos HTTP (ex: `["GET", "POST"]`, ou `["ANY"]`)               | Sim         |
| `api_key_required`| `bool`           | Define se a API Key é obrigatória para o método                           | Não (default: `false`) |

> 🔁 Se for passado `ANY`, ele será expandido internamente para `GET`, `POST`, `PUT`, `DELETE`, `PATCH`, `HEAD`, `OPTIONS`.

## Uso

```hcl
module "example_methods" {
  source        = "./modules/method"
  rest_api_id   = aws_api_gateway_rest_api.example.id
  resource_id   = aws_api_gateway_resource.example.id
  lambda_uri    = aws_lambda_function.example.invoke_arn
  authorization = "NONE"
  methods       = ["ANY"]
}
```

## Notas

- O método `OPTIONS` será configurado automaticamente com MOCK integration e CORS.
- A variável `lambda_uri` será usada para todos os métodos, exceto `OPTIONS`.
- Caso queira controle mais granular, forneça métodos explicitamente (ex: `["GET", "POST"]`).


