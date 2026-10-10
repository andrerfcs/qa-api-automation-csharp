Feature: OpenAPI Contract

  Scenario: Validar disponibilidade do contrato OpenAPI
    Given que a API FakeRESTAPI está disponível para validação de contrato
    When eu consultar o contrato OpenAPI
    Then o status code do contrato deve ser 200
    And o documento deve informar uma versão OpenAPI válida

  Scenario: Validar rotas de Books no contrato OpenAPI
    Given que o contrato OpenAPI foi obtido com sucesso
    Then o contrato deve conter a rota "/api/v1/Books"
    And o contrato deve conter a rota "/api/v1/Books/{id}"

  Scenario: Validar métodos HTTP de Books no contrato OpenAPI
    Given que o contrato OpenAPI foi obtido com sucesso
    Then a rota "/api/v1/Books" deve permitir o método "get"
    And a rota "/api/v1/Books" deve permitir o método "post"
    And a rota "/api/v1/Books/{id}" deve permitir o método "get"
    And a rota "/api/v1/Books/{id}" deve permitir o método "put"
    And a rota "/api/v1/Books/{id}" deve permitir o método "delete"

  Scenario: Validar schema Book no contrato OpenAPI
    Given que o contrato OpenAPI foi obtido com sucesso
    Then o schema "Book" deve existir no contrato
    And a propriedade "id" do schema "Book" deve ser do tipo "integer"
    And a propriedade "title" do schema "Book" deve ser do tipo "string"
    And a propriedade "description" do schema "Book" deve ser do tipo "string"
    And a propriedade "pageCount" do schema "Book" deve ser do tipo "integer"
    And a propriedade "excerpt" do schema "Book" deve ser do tipo "string"
    And a propriedade "publishDate" do schema "Book" deve ser do tipo "string"
    And a propriedade "publishDate" do schema "Book" deve possuir o formato "date-time"

  Scenario: Validar contrato de Authors no OpenAPI
    Given que o contrato OpenAPI foi obtido com sucesso
    Then o contrato deve conter a rota "/api/v1/Authors"
    And o contrato deve conter a rota "/api/v1/Authors/{id}"
    And o contrato deve conter a rota "/api/v1/Authors/authors/books/{idBook}"
    And a rota "/api/v1/Authors" deve permitir o método "get"
    And a rota "/api/v1/Authors" deve permitir o método "post"
    And a rota "/api/v1/Authors/{id}" deve permitir o método "get"
    And a rota "/api/v1/Authors/{id}" deve permitir o método "put"
    And a rota "/api/v1/Authors/{id}" deve permitir o método "delete"
    And a rota "/api/v1/Authors/authors/books/{idBook}" deve permitir o método "get"
    And o schema "Author" deve existir no contrato
    And a propriedade "id" do schema "Author" deve ser do tipo "integer"
    And a propriedade "idBook" do schema "Author" deve ser do tipo "integer"
    And a propriedade "firstName" do schema "Author" deve ser do tipo "string"
    And a propriedade "lastName" do schema "Author" deve ser do tipo "string"

  Scenario: Validar contrato de Activities no OpenAPI
    Given que o contrato OpenAPI foi obtido com sucesso
    Then o contrato deve conter a rota "/api/v1/Activities"
    And o contrato deve conter a rota "/api/v1/Activities/{id}"
    And a rota "/api/v1/Activities" deve permitir o método "get"
    And a rota "/api/v1/Activities" deve permitir o método "post"
    And a rota "/api/v1/Activities/{id}" deve permitir o método "get"
    And a rota "/api/v1/Activities/{id}" deve permitir o método "put"
    And a rota "/api/v1/Activities/{id}" deve permitir o método "delete"
    And o schema "Activity" deve existir no contrato
    And a propriedade "id" do schema "Activity" deve ser do tipo "integer"
    And a propriedade "title" do schema "Activity" deve ser do tipo "string"
    And a propriedade "dueDate" do schema "Activity" deve ser do tipo "string"
    And a propriedade "dueDate" do schema "Activity" deve possuir o formato "date-time"
    And a propriedade "completed" do schema "Activity" deve ser do tipo "boolean"

  Scenario: Validar contrato de CoverPhotos no OpenAPI
    Given que o contrato OpenAPI foi obtido com sucesso
    Then o contrato deve conter a rota "/api/v1/CoverPhotos"
    And o contrato deve conter a rota "/api/v1/CoverPhotos/{id}"
    And o contrato deve conter a rota "/api/v1/CoverPhotos/books/covers/{idBook}"
    And a rota "/api/v1/CoverPhotos" deve permitir o método "get"
    And a rota "/api/v1/CoverPhotos" deve permitir o método "post"
    And a rota "/api/v1/CoverPhotos/{id}" deve permitir o método "get"
    And a rota "/api/v1/CoverPhotos/{id}" deve permitir o método "put"
    And a rota "/api/v1/CoverPhotos/{id}" deve permitir o método "delete"
    And a rota "/api/v1/CoverPhotos/books/covers/{idBook}" deve permitir o método "get"
    And o schema "CoverPhoto" deve existir no contrato
    And a propriedade "id" do schema "CoverPhoto" deve ser do tipo "integer"
    And a propriedade "idBook" do schema "CoverPhoto" deve ser do tipo "integer"
    And a propriedade "url" do schema "CoverPhoto" deve ser do tipo "string"

  Scenario: Validar contrato de Users no OpenAPI
    Given que o contrato OpenAPI foi obtido com sucesso
    Then o contrato deve conter a rota "/api/v1/Users"
    And o contrato deve conter a rota "/api/v1/Users/{id}"
    And a rota "/api/v1/Users" deve permitir o método "get"
    And a rota "/api/v1/Users" deve permitir o método "post"
    And a rota "/api/v1/Users/{id}" deve permitir o método "get"
    And a rota "/api/v1/Users/{id}" deve permitir o método "put"
    And a rota "/api/v1/Users/{id}" deve permitir o método "delete"
    And o schema "User" deve existir no contrato
    And a propriedade "id" do schema "User" deve ser do tipo "integer"
    And a propriedade "userName" do schema "User" deve ser do tipo "string"
    And a propriedade "password" do schema "User" deve ser do tipo "string"