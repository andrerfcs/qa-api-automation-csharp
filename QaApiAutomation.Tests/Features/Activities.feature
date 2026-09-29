Feature: Activities API
  Como QA
  Quero validar os endpoints de Activities
  Para garantir o comportamento da API FakeRESTAPI

  Scenario: Listar atividades com sucesso
    Given que a API FakeRESTAPI está disponível para Activities
    When eu consultar todas as atividades
    Then o status code da resposta de Activities deve ser 200
    And a lista de atividades retornada não deve estar vazia

  Scenario: Consultar atividade por ID com sucesso
    Given que a API FakeRESTAPI está disponível para Activities
    When eu consultar a atividade com id 6
    Then o status code da resposta de Activities deve ser 200
    And a atividade retornada deve possuir id 6

  Scenario: Consultar atividade por ID inexistente
    Given que a API FakeRESTAPI está disponível para Activities
    When eu consultar a atividade com id 31
    Then o status code da resposta de Activities deve ser 404

  Scenario: Criar atividade com sucesso
    Given que a API FakeRESTAPI está disponível para Activities
    When eu criar uma nova atividade
    Then o status code da resposta de Activities deve ser 200
    And os dados da atividade retornada devem ser iguais aos enviados

  Scenario: Atualizar atividade existente com sucesso
    Given que a API FakeRESTAPI está disponível para Activities
    When eu atualizar a atividade com id 6
    Then o status code da resposta de Activities deve ser 200
    And os dados da atividade retornada devem ser iguais aos enviados

  Scenario: Atualizar atividade inexistente
    Given que a API FakeRESTAPI está disponível para Activities
    When eu atualizar a atividade com id 31
    Then o status code da resposta de Activities deve ser 200
    And os dados da atividade retornada devem ser iguais aos enviados

  Scenario: Excluir atividade existente
    Given que a API FakeRESTAPI está disponível para Activities
    When eu excluir a atividade com id 6
    Then o status code da resposta de Activities deve ser 200

  Scenario: Excluir atividade inexistente
    Given que a API FakeRESTAPI está disponível para Activities
    When eu excluir a atividade com id 31
    Then o status code da resposta de Activities deve ser 200
