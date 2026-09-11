using System.Text.Json;
using QaApiAutomation.Tests.Models;
using System.Net;
using Reqnroll;
using RestSharp;

namespace QaApiAutomation.Tests.StepDefinitions;

[Binding]
public class BooksSteps
{
    private static readonly JsonSerializerOptions JsonOptions = new()
    {
        PropertyNameCaseInsensitive = true
    };

    private RestClient _client = null!;
    private RestResponse _response = null!;

    private Book ObterLivroDaResposta()
    {
        var livro = JsonSerializer.Deserialize<Book>(
            _response.Content!,
            JsonOptions);

        Assert.That(livro, Is.Not.Null);

        return livro!;
    }

    [Given("que a API FakeRESTAPI está disponível")]
    public void GivenQueAApiFakeRestApiEstaDisponivel()
    {
        _client = new RestClient("https://fakerestapi.azurewebsites.net");
    }

    [When("eu enviar uma requisição GET para {string}")]
    public async Task WhenEuEnviarUmaRequisicaoGetPara(string endpoint)
    {
        var request = new RestRequest(endpoint, Method.Get);

        _response = await _client.ExecuteAsync(request);
    }

    [Then("o status code da resposta deve ser {int}")]
    public void ThenOStatusCodeDaRespostaDeveSer(int statusCodeEsperado)
    {
        Assert.That((int)_response.StatusCode, Is.EqualTo(statusCodeEsperado));
    }

    [Then("a resposta deve conter uma lista de livros")]
    public void ThenARespostaDeveConterUmaListaDeLivros()
    {
        Assert.That(_response.Content, Is.Not.Null.And.Not.Empty);

        var livros = JsonSerializer.Deserialize<List<Book>>(
            _response.Content!,
            JsonOptions);

        Assert.That(livros, Is.Not.Null);
        Assert.That(livros, Is.Not.Empty);
    }

    [Then("os livros retornados devem conter os campos {string} e {string}")]
    public void ThenOsLivrosRetornadosDevemConterOsCampos(
        string campo1,
        string campo2)
    {
        var livros = JsonSerializer.Deserialize<List<Book>>(
            _response.Content!,
            JsonOptions);

        Assert.That(livros, Is.Not.Null);
        Assert.That(livros, Is.Not.Empty);

        var primeiroLivro = livros![0];

        Assert.Multiple(() =>
        {
            Assert.That(primeiroLivro.Id, Is.GreaterThan(0));
            Assert.That(primeiroLivro.Title, Is.Not.Null.And.Not.Empty);
        });
    }

    [Then("o livro retornado deve possuir id igual a {int}")]
    public void ThenOLivroRetornadoDevePossuirIdIgualA(int idEsperado)
    {
        var livro = ObterLivroDaResposta();

        Assert.That(livro.Id, Is.EqualTo(idEsperado));
    }

    [Then("o título do livro retornado não deve estar vazio")]
    public void ThenOTituloDoLivroRetornadoNaoDeveEstarVazio()
    {
        var livro = ObterLivroDaResposta();

        Assert.That(livro.Title, Is.Not.Null.And.Not.Empty);
    }
}