using System.Text.Json;
using QaApiAutomation.Tests.Clients;
using QaApiAutomation.Tests.Configuration;
using QaApiAutomation.Tests.Models;
using Reqnroll;
using RestSharp;

namespace QaApiAutomation.Tests.StepDefinitions;

[Binding]
public class ActivitiesSteps
{
    private static readonly JsonSerializerOptions JsonOptions = new()
    {
        PropertyNameCaseInsensitive = true
    };

    private ActivitiesApiClient _client = null!;
    private RestResponse _response = null!;
    private Activity _atividadeEnviada = null!;

    private Activity ObterAtividadeDaResposta()
    {
        var atividade = JsonSerializer.Deserialize<Activity>(_response.Content!, JsonOptions);

        Assert.That(atividade, Is.Not.Null);

        return atividade!;
    }

    private static Activity CriarAtividadePayload(int id, string title, bool completed)
    {
        return new Activity
        {
            Id = id,
            Title = title,
            DueDate = new DateTime(2025, 2, 3, 4, 5, 6, DateTimeKind.Utc),
            Completed = completed
        };
    }

    [Given("que a API FakeRESTAPI está disponível para Activities")]
    public void GivenQueAApiFakeRestApiEstaDisponivelParaActivities()
    {
        _client = new ActivitiesApiClient(ApiSettings.BaseUrl);
    }

    [When("eu enviar uma requisição GET de Activities para {string}")]
    public async Task WhenEuEnviarUmaRequisicaoGetDeActivitiesPara(string endpoint)
    {
        if (endpoint.Equals("/api/v1/Activities", StringComparison.OrdinalIgnoreCase))
        {
            _response = await _client.ObterAtividadesAsync();
            return;
        }

        var id = int.Parse(endpoint.Substring(endpoint.LastIndexOf('/') + 1));
        _response = await _client.ObterAtividadeAsync(id);
    }

    [When("eu enviar uma requisição POST de Activities para {string} com uma nova atividade")]
    public async Task WhenEuEnviarUmaRequisicaoPostDeActivitiesParaComUmaNovaAtividade(string endpoint)
    {
        Assert.That(endpoint, Is.EqualTo("/api/v1/Activities"));
        _atividadeEnviada = CriarAtividadePayload(101, "Activity created by automation", true);
        _response = await _client.CriarAtividadeAsync(_atividadeEnviada);
    }

    [When("eu enviar uma requisição PUT de Activities para {string}")]
    public async Task WhenEuEnviarUmaRequisicaoPutDeActivitiesPara(string endpoint)
    {
        var id = int.Parse(endpoint.Substring(endpoint.LastIndexOf('/') + 1));
        _atividadeEnviada = CriarAtividadePayload(id, "Activity updated by automation", false);
        _response = await _client.AtualizarAtividadeAsync(id, _atividadeEnviada);
    }

    [When("eu enviar uma requisição DELETE de Activities para {string}")]
    public async Task WhenEuEnviarUmaRequisicaoDeleteDeActivitiesPara(string endpoint)
    {
        var id = int.Parse(endpoint.Substring(endpoint.LastIndexOf('/') + 1));
        _response = await _client.ExcluirAtividadeAsync(id);
    }

    [Then("o status code da resposta de Activities deve ser {int}")]
    public void ThenOStatusCodeDaRespostaDeActivitiesDeveSer(int statusCodeEsperado)
    {
        Assert.That((int)_response.StatusCode, Is.EqualTo(statusCodeEsperado));
    }

    [Then("a lista de atividades retornada não deve estar vazia")]
    public void ThenAListaDeAtividadesRetornadaNaoDeveEstarVazia()
    {
        Assert.That(_response.Content, Is.Not.Null.And.Not.Empty);

        var atividades = JsonSerializer.Deserialize<List<Activity>>(_response.Content!, JsonOptions);

        Assert.That(atividades, Is.Not.Null.And.Not.Empty);
    }

    [Then("a atividade retornada deve possuir id {int}")]
    public void ThenAAtividadeRetornadaDevePossuirId(int idEsperado)
    {
        Assert.That(ObterAtividadeDaResposta().Id, Is.EqualTo(idEsperado));
    }

    [Then("os dados da atividade retornada devem ser iguais aos enviados")]
    public void ThenOsDadosDaAtividadeRetornadaDevemSerIguaisAosEnviados()
    {
        var atividade = ObterAtividadeDaResposta();

        Assert.Multiple(() =>
        {
            Assert.That(atividade.Id, Is.EqualTo(_atividadeEnviada.Id));
            Assert.That(atividade.Title, Is.EqualTo(_atividadeEnviada.Title));
            Assert.That(atividade.DueDate, Is.EqualTo(_atividadeEnviada.DueDate));
            Assert.That(atividade.Completed, Is.EqualTo(_atividadeEnviada.Completed));
        });
    }
}
