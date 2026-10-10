using System.Text.Json;
using QaApiAutomation.Tests.Clients;
using QaApiAutomation.Tests.Configuration;
using Reqnroll;
using RestSharp;

namespace QaApiAutomation.Tests.StepDefinitions;

[Binding]
public class OpenApiContractSteps
{
    private OpenApiClient _client = null!;
    private RestResponse _response = null!;

    [Given("que a API FakeRESTAPI está disponível para validação de contrato")]
    public void GivenQueAApiFakeRestApiEstaDisponivelParaValidacaoDeContrato()
    {
        _client = new OpenApiClient(ApiSettings.BaseUrl);
    }

    [Given("que o contrato OpenAPI foi obtido com sucesso")]
    public async Task GivenQueOContratoOpenApiFoiObtidoComSucesso()
    {
        _client = new OpenApiClient(ApiSettings.BaseUrl);
        _response = await _client.ObterOpenApiAsync();

        Assert.That((int)_response.StatusCode, Is.EqualTo(200));
        Assert.That(_response.Content, Is.Not.Null.And.Not.Empty);
    }

    [When("eu consultar o contrato OpenAPI")]
    public async Task WhenEuConsultarOContratoOpenApi()
    {
        _response = await _client.ObterOpenApiAsync();
    }

    [Then("o status code do contrato deve ser 200")]
    public void ThenOStatusCodeDoContratoDeveSer200()
    {
        Assert.That((int)_response.StatusCode, Is.EqualTo(200));
    }

    [Then("o documento deve informar uma versão OpenAPI válida")]
    public void ThenODocumentoDeveInformarUmaVersaoOpenApiValida()
    {
        Assert.That(_response.Content, Is.Not.Null.And.Not.Empty);

        using var document = JsonDocument.Parse(_response.Content!);
        var root = document.RootElement;

        Assert.That(root.ValueKind, Is.EqualTo(JsonValueKind.Object));
        Assert.That(root.TryGetProperty("openapi", out var openApiVersion), Is.True);
        Assert.That(openApiVersion.ValueKind, Is.EqualTo(JsonValueKind.String));
        Assert.That(openApiVersion.GetString(), Is.Not.Null.And.Not.Empty);
    }

    [Then("o contrato deve conter a rota {string}")]
    public void ThenOContratoDeveConterARota(string route)
    {
        using var document = JsonDocument.Parse(_response.Content!);
        var root = document.RootElement;

        Assert.That(root.TryGetProperty("paths", out var paths), Is.True);
        Assert.That(paths.ValueKind, Is.EqualTo(JsonValueKind.Object));
        Assert.That(paths.TryGetProperty(route, out _), Is.True);
    }

    [Then("a rota {string} deve permitir o método {string}")]
    public void ThenARotaDevePermitirOMetodo(string route, string httpMethod)
    {
        using var document = JsonDocument.Parse(_response.Content!);
        var root = document.RootElement;

        Assert.That(root.TryGetProperty("paths", out var paths), Is.True);
        Assert.That(paths.ValueKind, Is.EqualTo(JsonValueKind.Object));
        Assert.That(paths.TryGetProperty(route, out var routeItem), Is.True);
        Assert.That(routeItem.ValueKind, Is.EqualTo(JsonValueKind.Object));
        Assert.That(routeItem.TryGetProperty(httpMethod.ToLowerInvariant(), out _), Is.True);
    }
}