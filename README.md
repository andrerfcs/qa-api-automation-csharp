# 🧪 QA API Automation — C#

[![CI](https://github.com/andrerfcs/qa-api-automation-csharp/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/andrerfcs/qa-api-automation-csharp/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/andrerfcs/qa-api-automation-csharp?label=release)](https://github.com/andrerfcs/qa-api-automation-csharp/releases/latest)
![.NET](https://img.shields.io/badge/.NET-8.0-512BD4)
![Reqnroll](https://img.shields.io/badge/BDD-Reqnroll-blue)

Projeto de automação de testes de API desenvolvido em **C# e .NET 8**, utilizando **Reqnroll**, **RestSharp**, **NUnit** e práticas de **BDD (Behavior Driven Development)**.

O objetivo deste projeto é demonstrar uma estrutura de automação organizada, escalável e próxima de cenários utilizados em projetos reais de QA, incluindo automação de APIs, CI/CD, análise de qualidade de código e dashboard de acompanhamento.

## 🚀 Tecnologias

- C#
- .NET 8
- Reqnroll
- RestSharp
- NUnit
- BDD / Gherkin
- REST API
- Git & GitHub
- GitHub Actions
- SonarQube Cloud
- HTML / CSS / JavaScript

## 🧪 APIs automatizadas

O inventário da FakeRESTAPI utilizado pelo projeto está automatizado nas seguintes Features:

- Activities
- Authors
- Books
- CoverPhotos
- Users

## 📊 Automação de testes

Estado atual da suíte:

- **5 Features automatizadas**
- **46 cenários automatizados**
- **48 execuções de testes**
- **48 testes aprovados**
- **0 falhas**
- **100% de sucesso na execução**

A diferença entre a quantidade de cenários e execuções ocorre devido aos exemplos utilizados em **Scenario Outline**.

Os testes contemplam:

- Cenários positivos
- Cenários negativos
- Validação de Status Code
- Validação de Response Body
- Operações GET, POST, PUT e DELETE
- Testes parametrizados
- Scenario Outline
- Reutilização de Steps
- Validação do comportamento observado da API

## 📂 Estrutura do projeto

O projeto utiliza separação de responsabilidades:

```text
QaApiAutomation.Tests
├── Clients
├── Configuration
├── Features
├── Models
└── StepDefinitions

dashboard
├── data
├── scripts
└── index.html

reports
└── generate-report.ps1

.github
└── workflows
    └── ci.yml
```

Principais responsabilidades:

- **Features** — cenários BDD escritos em Gherkin
- **StepDefinitions** — implementação dos passos Given / When / Then
- **Clients** — comunicação HTTP com os endpoints
- **Models** — representação dos contratos JSON
- **Configuration** — configurações da automação
- **Dashboard** — acompanhamento do inventário e execução
- **Reports** — geração do relatório HTML de execução a partir dos resultados TRX
- **GitHub Actions** — execução automatizada do pipeline

## ⚙️ Configuração da API

A URL base da FakeRESTAPI é definida pela variável de ambiente `API_BASE_URL`.

Caso a variável não esteja definida, os testes utilizam:

`https://fakerestapi.azurewebsites.net`

Para executar os testes contra outro ambiente:

```powershell
$env:API_BASE_URL = "https://qa.example.com"
dotnet test
```

Isso permite utilizar a mesma suíte em diferentes ambientes sem alterar o código.

## 🔄 CI/CD

O projeto possui pipeline de integração contínua utilizando **GitHub Actions**.

A cada Push ou Pull Request direcionado à `main`, o pipeline executa:

1. Checkout do repositório
2. Configuração do .NET 8
3. Restauração das dependências
4. Análise inicial do SonarQube Cloud
5. Build da solução
6. Execução dos testes automatizados
7. Geração do relatório HTML e publicação como artifact `execution-report`
8. Finalização da análise do SonarQube Cloud

O **Quality Gate** é utilizado para acompanhar a qualidade das alterações antes da integração à branch principal.

As etapas de geração e upload do relatório usam `if: always()`, permitindo disponibilizar as evidências mesmo quando a execução dos testes apresentar falhas.

## Test Execution Report

O pipeline gera os resultados dos testes em formato TRX e usa `reports/generate-report.ps1` para produzir `reports/execution-report.html`. O fluxo é:

**GitHub Actions → Test Execution → TRX → HTML Execution Report → Artifact**

O artifact **`execution-report`** pode ser baixado na execução correspondente do GitHub Actions. Ele contém o arquivo `execution-report.html`, com o resumo da execução, resultados agrupados por Feature, duração das execuções, passos BDD e detalhes de falha quando disponíveis.

Para gerar o relatório localmente, execute na raiz do repositório:

```powershell
dotnet test QaApiAutomation.sln --logger "trx;LogFileName=test-results.trx" --results-directory artifacts/test-results
.\reports\generate-report.ps1
```

O relatório será gerado em `reports/execution-report.html`.

## 🔍 Qualidade de código

O projeto está integrado ao **SonarQube Cloud** para análise contínua de qualidade.

A análise contempla:

- Qualidade e manutenibilidade do código
- Análise estática
- Duplicação de código
- Security Hotspots
- Quality Gate integrado ao fluxo de desenvolvimento

O dashboard web permanece sujeito à análise estática. O diretório `dashboard/**` é excluído apenas da métrica de cobertura, pois os testes automatizados em C# não executam o código JavaScript da interface.

## 📈 Dashboard

O projeto possui um dashboard próprio para acompanhamento da automação.

### Dashboard v1.1

Principais recursos:

- Resumo por Feature
- Indicadores globais de execução
- Cobertura do inventário de cenários
- Pesquisa e filtros
- Visualização de Given / When / Then
- Visualização de Scenario Outline / Examples
- Interface responsiva
- Indicadores de execução

> A cobertura exibida pelo dashboard representa a cobertura do **inventário de cenários definido pelo projeto**, e não uma medida absoluta de cobertura funcional de toda a API.

## ▶️ Executando o projeto

Clone o repositório:

```powershell
git clone https://github.com/andrerfcs/qa-api-automation-csharp.git
```

Acesse o projeto:

```powershell
cd qa-api-automation-csharp
```

Restaure as dependências:

```powershell
dotnet restore
```

Execute os testes:

```powershell
dotnet test
```

## 🏷️ Releases

O projeto utiliza **Semantic Versioning** para identificar suas versões estáveis.

Versão estável atual:

**v1.0.0 — First Stable Release**

A primeira versão estável representa a conclusão da automação do inventário utilizado da FakeRESTAPI, integração CI/CD, análise de qualidade e Dashboard v1.1.

## 🗺️ Próximas evoluções

Possíveis evoluções do projeto:

- Testes de contrato utilizando OpenAPI
- Evolução da estratégia de dados de teste
- Refatoração de componentes compartilhados conforme o projeto evoluir
- Publicação do dashboard
- Expansão da automação para novas APIs

## 👨‍💻 Autor

**André Silva**  
QA Engineer | Test Automation | API • Web • Mobile

GitHub: [github.com/andrerfcs](https://github.com/andrerfcs)

LinkedIn: linkedin.com/in/andrericardocsilva