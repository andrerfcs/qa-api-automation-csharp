# 🧪 QA API Automation — C#

Projeto de automação de testes de API desenvolvido em **C#**, utilizando **Reqnroll** e práticas de **BDD (Behavior Driven Development)**.

O objetivo deste projeto é demonstrar uma estrutura de automação organizada, escalável e próxima de cenários utilizados em projetos reais de QA.

## 🚀 Tecnologias

- C#
- .NET
- Reqnroll
- REST API
- BDD / Gherkin
- NUnit
- Git & GitHub
- GitHub Actions

## 🧪 Tipos de testes

O projeto será desenvolvido para contemplar cenários como:

- Testes positivos
- Testes negativos
- Validação de Status Code
- Validação de Response Body
- Validação de Headers
- Validação de contratos da API
- Testes parametrizados
- Reutilização de Steps
- Geração de evidências

## 📂 Estrutura do projeto

A estrutura será organizada utilizando separação de responsabilidades entre:

- Features
- Step Definitions
- Services / Clients
- Models
- Helpers
- Configurações
- Evidências e relatórios

## ⚙️ Configuração da API

A URL base da FakeRESTAPI é definida pela variável de ambiente `API_BASE_URL`. Se a variável não estiver definida, os testes usam `https://fakerestapi.azurewebsites.net`, preservando a configuração atual.

Para executar os testes contra um ambiente específico, defina a URL antes de executar `dotnet test`:

```powershell
$env:API_BASE_URL = "https://qa.example.com"
dotnet test
```

No CI/CD, configure `API_BASE_URL` com a URL correspondente ao ambiente DEV, QA ou PROD.

## 🔄 CI/CD

Os testes poderão ser executados automaticamente através do **GitHub Actions**, permitindo validação contínua do projeto.

## 📊 Próximas evoluções

- Implementação dos primeiros cenários de API
- Relatórios de execução
- Pipeline CI/CD
- Execução automática no GitHub Actions
- Dashboard de cobertura de testes
- Documentação dos endpoints testados

## 👨‍💻 Autor

**André Silva**  
QA Engineer | Test Automation | API • Web • Mobile

LinkedIn: linkedin.com/in/andrericardocsilva
