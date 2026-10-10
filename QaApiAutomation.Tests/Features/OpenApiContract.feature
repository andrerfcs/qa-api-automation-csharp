Feature: OpenAPI Contract

  Scenario: Validar disponibilidade do contrato OpenAPI
    Given que a API FakeRESTAPI está disponível para validação de contrato
    When eu consultar o contrato OpenAPI
    Then o status code do contrato deve ser 200
    And o documento deve informar uma versão OpenAPI válida