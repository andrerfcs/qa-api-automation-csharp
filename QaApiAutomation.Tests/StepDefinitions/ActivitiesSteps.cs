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

    [When("eu consultar todas as atividades")]
    public async Task WhenEuConsultarTodasAsAtividades()
    {
        _response = await _client.ObterAtividadesAsync();
    }

    [When("eu consultar a atividade com id {int}")]
    public async Task WhenEuConsultarAAtividadeComId(int id)
    {
        _response = await _client.ObterAtividadeAsync(id);
    }

    [When("eu criar uma nova atividade")]
    public async Task WhenEuCriarUmaNovaAtividade()
    {
        _atividadeEnviada = CriarAtividadePayload(101, "Activity created by automation", true);
        _response = await _client.CriarAtividadeAsync(_atividadeEnviada);
    }

    [When("eu atualizar a atividade com id {int}")]
    public async Task WhenEuAtualizarAAtividadeComId(int id)
    {
        _atividadeEnviada = CriarAtividadePayload(id, "Activity updated by automation", false);
        _response = await _client.AtualizarAtividadeAsync(id, _atividadeEnviada);
    }

    [When("eu excluir a atividade com id {int}")]
    public async Task WhenEuExcluirAAtividadeComId(int id)
    {
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
