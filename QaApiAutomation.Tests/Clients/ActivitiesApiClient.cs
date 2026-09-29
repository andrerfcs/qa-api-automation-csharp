using QaApiAutomation.Tests.Models;
using RestSharp;

namespace QaApiAutomation.Tests.Clients;

public class ActivitiesApiClient
{
    private readonly RestClient _client;

    public ActivitiesApiClient(string baseUrl)
    {
        _client = new RestClient(baseUrl);
    }

    public async Task<RestResponse> ObterAtividadesAsync()
    {
        var request = new RestRequest("/api/v1/Activities", Method.Get);

        return await _client.ExecuteAsync(request);
    }

    public async Task<RestResponse> ObterAtividadeAsync(int id)
    {
        var request = new RestRequest($"/api/v1/Activities/{id}", Method.Get);

        return await _client.ExecuteAsync(request);
    }

    public async Task<RestResponse> CriarAtividadeAsync(Activity atividade)
    {
        var request = new RestRequest("/api/v1/Activities", Method.Post);
        request.AddJsonBody(atividade);

        return await _client.ExecuteAsync(request);
    }

    public async Task<RestResponse> AtualizarAtividadeAsync(int id, Activity atividade)
    {
        var request = new RestRequest($"/api/v1/Activities/{id}", Method.Put);
        request.AddJsonBody(atividade);

        return await _client.ExecuteAsync(request);
    }

    public async Task<RestResponse> ExcluirAtividadeAsync(int id)
    {
        var request = new RestRequest($"/api/v1/Activities/{id}", Method.Delete);

        return await _client.ExecuteAsync(request);
    }
}
