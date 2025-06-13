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



