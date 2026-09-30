Feature: CoverPhotos

  Scenario: Listar CoverPhotos com sucesso
    Given que a API FakeRESTAPI está disponível para CoverPhotos
    When eu enviar uma requisição GET de CoverPhotos para "/api/v1/CoverPhotos"
    Then o status code da resposta de CoverPhotos deve ser 200
    And a resposta deve conter uma lista de CoverPhotos
    And as CoverPhotos retornadas devem conter os campos obrigatórios

  Scenario: Consultar CoverPhoto por ID com sucesso
    Given que a API FakeRESTAPI está disponível para CoverPhotos
    When eu enviar uma requisição GET de CoverPhotos para "/api/v1/CoverPhotos/1"
    Then o status code da resposta de CoverPhotos deve ser 200
    And a CoverPhoto retornada deve possuir id igual a 1

  Scenario: Consultar CoverPhoto por ID inexistente
    Given que a API FakeRESTAPI está disponível para CoverPhotos
    When eu enviar uma requisição GET de CoverPhotos para "/api/v1/CoverPhotos/201"
    Then o status code da resposta de CoverPhotos deve ser 404

  Scenario: Consultar CoverPhotos por ID do livro com sucesso
    Given que a API FakeRESTAPI está disponível para CoverPhotos
    When eu enviar uma requisição GET de CoverPhotos para "/api/v1/CoverPhotos/books/covers/1"
    Then o status code da resposta de CoverPhotos deve ser 200
    And todas as CoverPhotos retornadas devem possuir idBook igual a 1

  Scenario: Consultar CoverPhotos por ID de livro sem capas
    Given que a API FakeRESTAPI está disponível para CoverPhotos
    When eu enviar uma requisição GET de CoverPhotos para "/api/v1/CoverPhotos/books/covers/999999"
    Then o status code da resposta de CoverPhotos deve ser 200
    And a lista de CoverPhotos retornada deve estar vazia

  Scenario: Criar CoverPhoto com sucesso
    Given que a API FakeRESTAPI está disponível para CoverPhotos
    When eu enviar uma requisição POST de CoverPhotos para "/api/v1/CoverPhotos"
    Then o status code da resposta de CoverPhotos deve ser 200
    And os dados da CoverPhoto retornada devem ser iguais aos enviados

  Scenario: Atualizar CoverPhoto existente
    Given que a API FakeRESTAPI está disponível para CoverPhotos
    When eu enviar uma requisição PUT de CoverPhotos para "/api/v1/CoverPhotos/1"
    Then o status code da resposta de CoverPhotos deve ser 200
    And os dados da CoverPhoto retornada devem ser iguais aos enviados

  Scenario: Atualizar CoverPhoto inexistente
    Given que a API FakeRESTAPI está disponível para CoverPhotos
    When eu enviar uma requisição PUT de CoverPhotos para "/api/v1/CoverPhotos/201"
    Then o status code da resposta de CoverPhotos deve ser 200
    And os dados da CoverPhoto retornada devem ser iguais aos enviados

  Scenario: Excluir CoverPhoto existente
    Given que a API FakeRESTAPI está disponível para CoverPhotos
    When eu enviar uma requisição DELETE de CoverPhotos para "/api/v1/CoverPhotos/1"
    Then o status code da resposta de CoverPhotos deve ser 200

  Scenario: Excluir CoverPhoto inexistente
    Given que a API FakeRESTAPI está disponível para CoverPhotos
    When eu enviar uma requisição DELETE de CoverPhotos para "/api/v1/CoverPhotos/201"
    Then o status code da resposta de CoverPhotos deve ser 200