using RestSharp;

namespace QaApiAutomation.Tests.Clients;

public class OpenApiClient
{
    private readonly RestClient _client;

    public OpenApiClient(string baseUrl)
    {
        _client = new RestClient(baseUrl);
    }

    public async Task<RestResponse> ObterOpenApiAsync()
    {
        var request = new RestRequest("/swagger/v1/swagger.json", Method.Get);

        return await _client.ExecuteAsync(request);
    }
}