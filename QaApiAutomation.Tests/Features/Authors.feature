Feature: Authors

  Scenario: Listar autores com sucesso
    Given que a API FakeRESTAPI está disponível para Authors
    When eu enviar uma requisição GET de Authors para "/api/v1/Authors"
    Then o status code da resposta de Authors deve ser 200
    And a resposta deve conter uma lista de autores
    And os autores retornados devem conter os campos obrigatórios

  Scenario: Consultar autor por ID com sucesso
    Given que a API FakeRESTAPI está disponível para Authors
    When eu enviar uma requisição GET de Authors para "/api/v1/Authors/1"
    Then o status code da resposta de Authors deve ser 200
    And o autor retornado deve possuir id igual a 1
    And o autor retornado deve possuir idBook igual a 1
    And os nomes do autor retornado não devem estar vazios

  Scenario: Consultar autor por ID inexistente
    Given que a API FakeRESTAPI está disponível para Authors
    When eu enviar uma requisição GET de Authors para "/api/v1/Authors/999999"
    Then o status code da resposta de Authors deve ser 404

  Scenario: Criar autor com sucesso
    Given que a API FakeRESTAPI está disponível para Authors
    When eu enviar uma requisição POST de Authors para "/api/v1/Authors" com um novo autor
    Then o status code da resposta de Authors deve ser 200
    And o id do autor retornado deve ser igual ao enviado
    And o idBook do autor retornado deve ser igual ao enviado
    And os nomes do autor retornado devem ser iguais aos enviados

  Scenario: Atualizar autor com sucesso
    Given que a API FakeRESTAPI está disponível para Authors
    When eu enviar uma requisição PUT de Authors para "/api/v1/Authors/1" com um autor atualizado
    Then o status code da resposta de Authors deve ser 200
    And os dados do autor retornado devem ser iguais aos enviados

  Scenario: Tentar atualizar autor com ID inexistente
    Given que a API FakeRESTAPI está disponível para Authors
    When eu enviar uma requisição PUT de Authors para "/api/v1/Authors/999999" com um autor válido e ID inexistente
    Then o status code da resposta de Authors deve ser 200
    And os dados do autor retornado devem ser iguais aos enviados

  Scenario: Excluir autor com sucesso
    Given que a API FakeRESTAPI está disponível para Authors
    When eu enviar uma requisição DELETE de Authors para "/api/v1/Authors/1"
    Then o status code da resposta de Authors deve ser 200

  Scenario: Tentar excluir autor com ID inexistente
    Given que a API FakeRESTAPI está disponível para Authors
    When eu enviar uma requisição DELETE de Authors para "/api/v1/Authors/999999"
    Then o status code da resposta de Authors deve ser 200

  Scenario: Consultar autores por ID do livro com sucesso
    Given que a API FakeRESTAPI está disponível para Authors
    When eu consultar autores vinculados ao livro com idBook 1
    Then o status code da resposta de Authors deve ser 200
    And todos os autores retornados devem possuir idBook igual a 1

  Scenario: Consultar autores por ID de livro sem autores
    Given que a API FakeRESTAPI está disponível para Authors
    When eu consultar autores vinculados ao livro com idBook 999999
    Then o status code da resposta de Authors deve ser 200
    And a lista de autores retornada deve estar vazia
