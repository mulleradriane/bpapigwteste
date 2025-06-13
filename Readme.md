# bpapigwteste – Blueprint API Gateway + Lambda

## ✅ O que já foi implementado

- [x] **Módulo `api`**
  - Criação do REST API com nome/descrição
- [x] **Módulo `resource`**
  - Endpoint `/hello` criado com `parent_id`
- [x] **Módulo `lambda`**
  - Função Lambda `hello-lambda` criada com IAM Role apropriada
- [x] **Módulo `method`**
  - `for_each` para criar métodos: `GET`, `POST`, `PUT`, `OPTIONS`
  - Integração Lambda Proxy nos métodos `GET`, `POST`, `PUT`
  - Integração Mock para `OPTIONS`
  - Method Response + Integration Response com `depends_on`
- [x] **Módulo `deployment`**
  - Deployment + Stage `dev`, disparado com `sha1(...)` ou `timestamp()`
  - Recebe `method_configs` para garantir dependência entre métodos e deploy

## 🚧 O que ainda falta

- [ ] Cleanup de `null_resource.wait_for_methods` após migração para `method_configs`
- [ ] Modularização mais completa: mover `method_configs` para outputs do módulo `method`
- [ ] Optionais/CORS avançado:
  - Validadores de body/querystring/headers
  - Autorização IAM ou tokens (se desejar)
  - Proxy resource genérico (`/{proxy+}`) se quiser rotas flexíveis

## 🔍 Comparação com `terraform-aws-apigateway-v2`

- Esse módulo oficial lida com o API Gateway V2 (HTTP/WebSocket), enquanto usamos V1 (REST)
- Ele propõe:
  - Interfaces declarativas estruturadas (`method_settings`, `cors_configuration`)
  - Triggers baseados em SHA para deploys condicionais
  - Outputs melhorados (URLs, ARNs, IDs)
- Nosso Blueprint segue estrutura semelhante: modular, decomposto e reutilizável
- Próximos passos:
  - Implementar `locals`, `validation_settings`, `cors_configuration`
  - Remover null_resource e alinhar triggers base SHA1
  - Atualizar outputs com informações adicionais (ex: `websocket_url`, `api_gateway_domain_name` se desejar custom domain)


