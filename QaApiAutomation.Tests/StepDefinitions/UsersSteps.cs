using System.Text.Json;
using QaApiAutomation.Tests.Clients;
using QaApiAutomation.Tests.Configuration;
using QaApiAutomation.Tests.Models;
using Reqnroll;
using RestSharp;

namespace QaApiAutomation.Tests.StepDefinitions;

[Binding]
public class UsersSteps
{
    private static readonly JsonSerializerOptions JsonOptions = new()
    {
        PropertyNameCaseInsensitive = true
    };

    private UsersApiClient _client = null!;
    private RestResponse _response = null!;
    private User _userEnviado = null!;

    private User ObterUserDaResposta()
    {
        var user = JsonSerializer.Deserialize<User>(_response.Content!, JsonOptions);

        Assert.That(user, Is.Not.Null);

        return user!;
    }

    private List<User> ObterUsersDaResposta()
    {
        Assert.That(_response.Content, Is.Not.Null.And.Not.Empty);

        var users = JsonSerializer.Deserialize<List<User>>(_response.Content!, JsonOptions);

        Assert.That(users, Is.Not.Null);

        return users!;
    }

    [Given("que a API FakeRESTAPI está disponível para Users")]
    public void GivenQueAApiFakeRestApiEstaDisponivelParaUsers()
    {
        _client = new UsersApiClient(ApiSettings.BaseUrl);
    }

    [When("eu enviar uma requisição GET de Users para {string}")]
    public async Task WhenEuEnviarUmaRequisicaoGetDeUsersPara(string endpoint)
    {
        _response = await _client.ObterUsersAsync(endpoint);
    }

    [When("eu enviar uma requisição POST de Users para {string}")]
    public async Task WhenEuEnviarUmaRequisicaoPostDeUsersPara(string endpoint)
    {
        _userEnviado = new User
        {
            Id = 11,
            UserName = "User Automation",
            Password = "PasswordAutomation"
        };

        _response = await _client.CriarUserAsync(endpoint, _userEnviado);
    }

    [When("eu enviar uma requisição PUT de Users para {string}")]
    public async Task WhenEuEnviarUmaRequisicaoPutDeUsersPara(string endpoint)
    {
        var id = int.Parse(endpoint.Split('/').Last());

        _userEnviado = new User
        {
            Id = id,
            UserName = "User Updated",
            Password = "PasswordUpdated"
        };

        _response = await _client.AtualizarUserAsync(endpoint, _userEnviado);
    }

    [When("eu enviar uma requisição DELETE de Users para {string}")]
    public async Task WhenEuEnviarUmaRequisicaoDeleteDeUsersPara(string endpoint)
    {
        _response = await _client.ExcluirUserAsync(endpoint);
    }

    [Then("o status code da resposta de Users deve ser {int}")]
    public void ThenOStatusCodeDaRespostaDeUsersDeveSer(int statusCodeEsperado)
    {
        Assert.That((int)_response.StatusCode, Is.EqualTo(statusCodeEsperado));
    }

    [Then("a resposta deve conter uma lista de Users")]
    public void ThenARespostaDeveConterUmaListaDeUsers()
    {
        Assert.That(ObterUsersDaResposta(), Is.Not.Empty);
    }

    [Then("os Users retornados devem conter os campos obrigatórios")]
    public void ThenOsUsersRetornadosDevemConterOsCamposObrigatorios()
    {
        var primeiroUser = ObterUsersDaResposta()[0];

        Assert.Multiple(() =>
        {
            Assert.That(primeiroUser.Id, Is.GreaterThan(0));
            Assert.That(primeiroUser.UserName, Is.Not.Null.And.Not.Empty);
            Assert.That(primeiroUser.Password, Is.Not.Null.And.Not.Empty);
        });
    }

    [Then("o User retornado deve possuir id igual a {int}")]
    public void ThenOUserRetornadoDevePossuirIdIgualA(int idEsperado)
    {
        Assert.That(ObterUserDaResposta().Id, Is.EqualTo(idEsperado));
    }

    [Then("os dados do User retornado devem ser iguais aos enviados")]
    public void ThenOsDadosDoUserRetornadoDevemSerIguaisAosEnviados()
    {
        var user = ObterUserDaResposta();

        Assert.Multiple(() =>
        {
            Assert.That(user.Id, Is.EqualTo(_userEnviado.Id));
            Assert.That(user.UserName, Is.EqualTo(_userEnviado.UserName));
            Assert.That(user.Password, Is.EqualTo(_userEnviado.Password));
        });
    }
}