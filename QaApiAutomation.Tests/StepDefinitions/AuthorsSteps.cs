using System.Text.Json;
using QaApiAutomation.Tests.Clients;
using QaApiAutomation.Tests.Configuration;
using QaApiAutomation.Tests.Models;
using Reqnroll;
using RestSharp;

namespace QaApiAutomation.Tests.StepDefinitions;

[Binding]
public class AuthorsSteps
{
    private static readonly JsonSerializerOptions JsonOptions = new()
    {
        PropertyNameCaseInsensitive = true
    };

    private AuthorsApiClient _client = null!;
    private RestResponse _response = null!;
    private Author _autorEnviado = null!;

    private Author ObterAutorDaResposta()
    {
        var autor = JsonSerializer.Deserialize<Author>(_response.Content!, JsonOptions);

        Assert.That(autor, Is.Not.Null);

        return autor!;
    }

    [Given("que a API FakeRESTAPI está disponível para Authors")]
    public void GivenQueAApiFakeRestApiEstaDisponivelParaAuthors()
    {
        _client = new AuthorsApiClient(ApiSettings.BaseUrl);
    }

    [When("eu enviar uma requisição GET de Authors para {string}")]
    public async Task WhenEuEnviarUmaRequisicaoGetDeAuthorsPara(string endpoint)
    {
        _response = await _client.ObterAutoresAsync(endpoint);
    }

    [When("eu enviar uma requisição POST de Authors para {string} com um novo autor")]
    public async Task WhenEuEnviarUmaRequisicaoPostDeAuthorsParaComUmNovoAutor(string endpoint)
    {
        _autorEnviado = new Author
        {
            Id = 605,
            IdBook = 1,
            FirstName = "Author created by automation",
            LastName = "FakeRESTAPI test"
        };

        _response = await _client.CriarAutorAsync(endpoint, _autorEnviado);
    }

    [Then("o status code da resposta de Authors deve ser {int}")]
    public void ThenOStatusCodeDaRespostaDeAuthorsDeveSer(int statusCodeEsperado)
    {
        Assert.That((int)_response.StatusCode, Is.EqualTo(statusCodeEsperado));
    }

    [Then("a resposta deve conter uma lista de autores")]
    public void ThenARespostaDeveConterUmaListaDeAutores()
    {
        var autores = ObterAutoresDaResposta();

        Assert.That(autores, Is.Not.Empty);
    }

    [Then("os autores retornados devem conter os campos obrigatórios")]
    public void ThenOsAutoresRetornadosDevemConterOsCamposObrigatorios()
    {
        var autores = ObterAutoresDaResposta();
        var primeiroAutor = autores[0];

        Assert.Multiple(() =>
        {
            Assert.That(primeiroAutor.Id, Is.GreaterThan(0));
            Assert.That(primeiroAutor.IdBook, Is.GreaterThan(0));
            Assert.That(primeiroAutor.FirstName, Is.Not.Null.And.Not.Empty);
            Assert.That(primeiroAutor.LastName, Is.Not.Null.And.Not.Empty);
        });
    }

    [Then("o autor retornado deve possuir id igual a {int}")]
    public void ThenOAutorRetornadoDevePossuirIdIgualA(int idEsperado)
    {
        Assert.That(ObterAutorDaResposta().Id, Is.EqualTo(idEsperado));
    }

    [Then("o autor retornado deve possuir idBook igual a {int}")]
    public void ThenOAutorRetornadoDevePossuirIdBookIgualA(int idBookEsperado)
    {
        Assert.That(ObterAutorDaResposta().IdBook, Is.EqualTo(idBookEsperado));
    }

    [Then("os nomes do autor retornado não devem estar vazios")]
    public void ThenOsNomesDoAutorRetornadoNaoDevemEstarVazios()
    {
        var autor = ObterAutorDaResposta();

        Assert.Multiple(() =>
        {
            Assert.That(autor.FirstName, Is.Not.Null.And.Not.Empty);
            Assert.That(autor.LastName, Is.Not.Null.And.Not.Empty);
        });
    }

    [Then("o id do autor retornado deve ser igual ao enviado")]
    public void ThenOIdDoAutorRetornadoDeveSerIgualAoEnviado()
    {
        Assert.That(ObterAutorDaResposta().Id, Is.EqualTo(_autorEnviado.Id));
    }

    [Then("o idBook do autor retornado deve ser igual ao enviado")]
    public void ThenOIdBookDoAutorRetornadoDeveSerIgualAoEnviado()
    {
        Assert.That(ObterAutorDaResposta().IdBook, Is.EqualTo(_autorEnviado.IdBook));
    }

    [Then("os nomes do autor retornado devem ser iguais aos enviados")]
    public void ThenOsNomesDoAutorRetornadoDevemSerIguaisAosEnviados()
    {
        var autor = ObterAutorDaResposta();

        Assert.Multiple(() =>
        {
            Assert.That(autor.FirstName, Is.EqualTo(_autorEnviado.FirstName));
            Assert.That(autor.LastName, Is.EqualTo(_autorEnviado.LastName));
        });
    }

    private List<Author> ObterAutoresDaResposta()
    {
        Assert.That(_response.Content, Is.Not.Null.And.Not.Empty);

        var autores = JsonSerializer.Deserialize<List<Author>>(_response.Content!, JsonOptions);

        Assert.That(autores, Is.Not.Null);

        return autores!;
    }
}
