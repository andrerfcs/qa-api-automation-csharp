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

    [Then("o status code da resposta deve ser 200")]
    public void ThenOStatusCodeDaRespostaDeveSer200()
    {
        Assert.That(_response.StatusCode, Is.EqualTo(HttpStatusCode.OK));
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
    public void ThenOsLivrosRetornadosDevemConterOsCampos(string campo1, string campo2)
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
}