Feature: Books

  Scenario: Listar livros com sucesso
    Given que a API FakeRESTAPI está disponível
    When eu enviar uma requisição GET para "/api/v1/Books"
    Then o status code da resposta deve ser 200
    And a resposta deve conter uma lista de livros
    And os livros retornados devem conter os campos "id" e "title"

  Scenario: Consultar livro por ID com sucesso
    Given que a API FakeRESTAPI está disponível
    When eu enviar uma requisição GET para "/api/v1/Books/1"
    Then o status code da resposta deve ser 200
    And o livro retornado deve possuir id igual a 1
    And o título do livro retornado não deve estar vazio