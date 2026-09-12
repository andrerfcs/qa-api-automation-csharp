using System.Text.Json;
using QaApiAutomation.Tests.Clients;
using QaApiAutomation.Tests.Models;
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

    private BooksApiClient _client = null!;
    private RestResponse _response = null!;
    private Book _livroEnviado = null!;

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
        _client = new BooksApiClient();
    }

    [When("eu enviar uma requisição GET para {string}")]
    public async Task WhenEuEnviarUmaRequisicaoGetPara(string endpoint)
    {
        _response = await _client.ObterLivrosAsync(endpoint);
    }

    [When("eu enviar uma requisição POST para {string} com um novo livro")]
    public async Task WhenEuEnviarUmaRequisicaoPostParaComUmNovoLivro(string endpoint)
    {
        _livroEnviado = new Book
        {
            Id = 101,
            Title = "Livro criado com sucesso",
            Description = "Descrição do livro criado no teste",
            PageCount = 200,
            Excerpt = "Trecho do livro criado no teste",
            PublishDate = new DateTime(2024, 1, 15)
        };

        _response = await _client.CriarLivroAsync(endpoint, _livroEnviado);
    }

    [When("eu enviar uma requisição PUT para {string} com um livro atualizado")]
    public async Task WhenEuEnviarUmaRequisicaoPutParaComUmLivroAtualizado(string endpoint)
    {
        _livroEnviado = new Book
        {
            Id = 1,
            Title = "Livro atualizado com sucesso",
            Description = "Descrição atualizada do livro no teste",
            PageCount = 250,
            Excerpt = "Trecho atualizado do livro no teste",
            PublishDate = new DateTime(2025, 2, 20)
        };

        _response = await _client.AtualizarLivroAsync(endpoint, _livroEnviado);
    }

    [When("eu enviar uma requisição DELETE para {string}")]
    public async Task WhenEuEnviarUmaRequisicaoDeletePara(string endpoint)
    {
        _response = await _client.ExcluirLivroAsync(endpoint);
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

    [Then("o id do livro retornado deve ser igual ao enviado")]
    public void ThenOIdDoLivroRetornadoDeveSerIgualAoEnviado()
    {
        var livro = ObterLivroDaResposta();

        Assert.That(livro.Id, Is.EqualTo(_livroEnviado.Id));
    }

    [Then("o título do livro retornado deve ser igual ao enviado")]
    public void ThenOTituloDoLivroRetornadoDeveSerIgualAoEnviado()
    {
        var livro = ObterLivroDaResposta();

        Assert.That(livro.Title, Is.EqualTo(_livroEnviado.Title));
    }
}