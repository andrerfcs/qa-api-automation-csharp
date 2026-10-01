Feature: Users

  Scenario: Listar usuários com sucesso
    Given que a API FakeRESTAPI está disponível para Users
    When eu enviar uma requisição GET de Users para "/api/v1/Users"
    Then o status code da resposta de Users deve ser 200
    And a resposta deve conter uma lista de Users
    And os Users retornados devem conter os campos obrigatórios

  Scenario: Consultar usuário por ID com sucesso
    Given que a API FakeRESTAPI está disponível para Users
    When eu enviar uma requisição GET de Users para "/api/v1/Users/1"
    Then o status code da resposta de Users deve ser 200
    And o User retornado deve possuir id igual a 1

  Scenario: Consultar usuário por ID inexistente
    Given que a API FakeRESTAPI está disponível para Users
    When eu enviar uma requisição GET de Users para "/api/v1/Users/11"
    Then o status code da resposta de Users deve ser 404

  Scenario: Criar usuário com sucesso
    Given que a API FakeRESTAPI está disponível para Users
    When eu enviar uma requisição POST de Users para "/api/v1/Users"
    Then o status code da resposta de Users deve ser 200
    And os dados do User retornado devem ser iguais aos enviados

  Scenario: Atualizar usuário existente com sucesso
    Given que a API FakeRESTAPI está disponível para Users
    When eu enviar uma requisição PUT de Users para "/api/v1/Users/1"
    Then o status code da resposta de Users deve ser 200
    And os dados do User retornado devem ser iguais aos enviados

  Scenario: Atualizar usuário inexistente
    Given que a API FakeRESTAPI está disponível para Users
    When eu enviar uma requisição PUT de Users para "/api/v1/Users/11"
    Then o status code da resposta de Users deve ser 200
    And os dados do User retornado devem ser iguais aos enviados

  Scenario: Excluir usuário existente
    Given que a API FakeRESTAPI está disponível para Users
    When eu enviar uma requisição DELETE de Users para "/api/v1/Users/1"
    Then o status code da resposta de Users deve ser 200

  Scenario: Excluir usuário inexistente
    Given que a API FakeRESTAPI está disponível para Users
    When eu enviar uma requisição DELETE de Users para "/api/v1/Users/11"
    Then o status code da resposta de Users deve ser 200