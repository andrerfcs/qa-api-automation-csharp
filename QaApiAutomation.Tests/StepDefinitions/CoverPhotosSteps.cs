using System.Text.Json;
using QaApiAutomation.Tests.Clients;
using QaApiAutomation.Tests.Configuration;
using QaApiAutomation.Tests.Models;
using Reqnroll;
using RestSharp;

namespace QaApiAutomation.Tests.StepDefinitions;

[Binding]
public class CoverPhotosSteps
{
    private static readonly JsonSerializerOptions JsonOptions = new()
    {
        PropertyNameCaseInsensitive = true
    };

    private CoverPhotosApiClient _client = null!;
    private RestResponse _response = null!;
    private CoverPhoto _coverPhotoEnviada = null!;

    private CoverPhoto ObterCoverPhotoDaResposta()
    {
        var coverPhoto = JsonSerializer.Deserialize<CoverPhoto>(_response.Content!, JsonOptions);

        Assert.That(coverPhoto, Is.Not.Null);

        return coverPhoto!;
    }

    private List<CoverPhoto> ObterCoverPhotosDaResposta()
    {
        Assert.That(_response.Content, Is.Not.Null.And.Not.Empty);

        var coverPhotos = JsonSerializer.Deserialize<List<CoverPhoto>>(_response.Content!, JsonOptions);

        Assert.That(coverPhotos, Is.Not.Null);

        return coverPhotos!;
    }

    [Given("que a API FakeRESTAPI está disponível para CoverPhotos")]
    public void GivenQueAApiFakeRestApiEstaDisponivelParaCoverPhotos()
    {
        _client = new CoverPhotosApiClient(ApiSettings.BaseUrl);
    }

    [When("eu enviar uma requisição GET de CoverPhotos para {string}")]
    public async Task WhenEuEnviarUmaRequisicaoGetDeCoverPhotosPara(string endpoint)
    {
        _response = await _client.ObterCoverPhotosAsync(endpoint);
    }

    [When("eu enviar uma requisição POST de CoverPhotos para {string}")]
    public async Task WhenEuEnviarUmaRequisicaoPostDeCoverPhotosPara(string endpoint)
    {
        _coverPhotoEnviada = new CoverPhoto
        {
            Id = 201,
            IdBook = 1,
            Url = "https://example.com/cover-automation.jpg"
        };

        _response = await _client.CriarCoverPhotoAsync(endpoint, _coverPhotoEnviada);
    }

    [When("eu enviar uma requisição PUT de CoverPhotos para {string}")]
    public async Task WhenEuEnviarUmaRequisicaoPutDeCoverPhotosPara(string endpoint)
    {
        var id = int.Parse(endpoint.Split('/').Last());

        _coverPhotoEnviada = new CoverPhoto
        {
            Id = id,
            IdBook = 1,
            Url = "https://example.com/cover-updated.jpg"
        };

        _response = await _client.AtualizarCoverPhotoAsync(endpoint, _coverPhotoEnviada);
    }

    [When("eu enviar uma requisição DELETE de CoverPhotos para {string}")]
    public async Task WhenEuEnviarUmaRequisicaoDeleteDeCoverPhotosPara(string endpoint)
    {
        _response = await _client.ExcluirCoverPhotoAsync(endpoint);
    }

    [Then("o status code da resposta de CoverPhotos deve ser {int}")]
    public void ThenOStatusCodeDaRespostaDeCoverPhotosDeveSer(int statusCodeEsperado)
    {
        Assert.That((int)_response.StatusCode, Is.EqualTo(statusCodeEsperado));
    }

    [Then("a resposta deve conter uma lista de CoverPhotos")]
    public void ThenARespostaDeveConterUmaListaDeCoverPhotos()
    {
        Assert.That(ObterCoverPhotosDaResposta(), Is.Not.Empty);
    }

    [Then("as CoverPhotos retornadas devem conter os campos obrigatórios")]
    public void ThenAsCoverPhotosRetornadasDevemConterOsCamposObrigatorios()
    {
        var primeiraCoverPhoto = ObterCoverPhotosDaResposta()[0];

        Assert.Multiple(() =>
        {
            Assert.That(primeiraCoverPhoto.Id, Is.GreaterThan(0));
            Assert.That(primeiraCoverPhoto.IdBook, Is.GreaterThan(0));
            Assert.That(primeiraCoverPhoto.Url, Is.Not.Null.And.Not.Empty);
        });
    }

    [Then("a CoverPhoto retornada deve possuir id igual a {int}")]
    public void ThenACoverPhotoRetornadaDevePossuirIdIgualA(int idEsperado)
    {
        Assert.That(ObterCoverPhotoDaResposta().Id, Is.EqualTo(idEsperado));
    }

    [Then("todas as CoverPhotos retornadas devem possuir idBook igual a {int}")]
    public void ThenTodasAsCoverPhotosRetornadasDevemPossuirIdBookIgualA(int idBookEsperado)
    {
        var coverPhotos = ObterCoverPhotosDaResposta();

        Assert.That(coverPhotos, Is.Not.Empty);
        Assert.That(coverPhotos, Has.All.Property(nameof(CoverPhoto.IdBook)).EqualTo(idBookEsperado));
    }

    [Then("a lista de CoverPhotos retornada deve estar vazia")]
    public void ThenAListaDeCoverPhotosRetornadaDeveEstarVazia()
    {
        Assert.That(ObterCoverPhotosDaResposta(), Is.Empty);
    }

    [Then("os dados da CoverPhoto retornada devem ser iguais aos enviados")]
    public void ThenOsDadosDaCoverPhotoRetornadaDevemSerIguaisAosEnviados()
    {
        var coverPhoto = ObterCoverPhotoDaResposta();

        Assert.Multiple(() =>
        {
            Assert.That(coverPhoto.Id, Is.EqualTo(_coverPhotoEnviada.Id));
            Assert.That(coverPhoto.IdBook, Is.EqualTo(_coverPhotoEnviada.IdBook));
            Assert.That(coverPhoto.Url, Is.EqualTo(_coverPhotoEnviada.Url));
        });
    }
}