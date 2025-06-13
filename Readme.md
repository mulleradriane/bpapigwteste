# 🧱 Blueprint Terraform - API Gateway + Lambda

Este projeto define uma **infraestrutura modularizada** com **AWS API Gateway + Lambda** usando Terraform. Ele permite criar, estender e publicar endpoints HTTP totalmente gerenciados, com integração Lambda.

---

## 📁 Estrutura de Diretórios

bpapigwteste/
├── hello.zip # Código compactado da Lambda
├── index.js # Código-fonte da Lambda
├── main.tf # Módulo raiz com chamadas principais
├── variables.tf
├── outputs.tf
├── terraform.tfstate*
├── modules/
│ ├── api/
│ │ ├── main.tf
│ │ ├── outputs.tf
│ │ └── variables.tf
│ ├── resource/
│ │ ├── main.tf
│ │ ├── outputs.tf
│ │ └── variables.tf
│ ├── lambda/
│ │ ├── main.tf
│ │ ├── outputs.tf
│ │ └── variables.tf
│ └── method/
│ ├── main.tf
│ ├── outputs.tf
│ └── variables.tf



---

## ✅ Funcionalidades Implementadas

| Etapa | Módulo         | Descrição                                                                 |
|-------|----------------|--------------------------------------------------------------------------|
| 1     | `api`          | Criação do API Gateway REST (`aws_api_gateway_rest_api`)                |
| 2     | `resource`     | Criação de um recurso `/hello`                                          |
| 3     | `lambda`       | Criação de uma função Lambda chamada `hello-lambda`                     |
| 4     | `method`       | Criação do método HTTP `GET` com integração via proxy para a Lambda     |

---

## 🔧 Fluxo Terraform Executado

1. **API Gateway** criado com nome e descrição personalizados.
2. **Recurso `/hello`** criado dentro da API.
3. **Função Lambda** criada com handler `index.handler` e runtime `nodejs18.x`.
4. **Método `GET`** configurado no `/hello` com integração `AWS_PROXY` para a Lambda.

---

## 🧪 Testes

Após aplicar os módulos, foi verificado no console do API Gateway:



---

## 🚧 Próximos Passos

- [ ] Criar `deployment` e `stage` para publicar a API
- [ ] Adicionar suporte a CORS
- [ ] Criar métodos adicionais (POST, PUT, DELETE, etc.)
- [ ] Implementar validações e autenticação (API Key, IAM, Cognito)
- [ ] Adicionar logs, caching e throttling

---

## 📜 Requisitos

- Terraform >= 1.0
- AWS CLI configurado (`aws configure`)
- `hello.zip` contendo o código da função Lambda

---

## ✉️ Contato

Este projeto está em construção como base para arquiteturas serverless modulares.  
Contribuições e melhorias são bem-vindas!

