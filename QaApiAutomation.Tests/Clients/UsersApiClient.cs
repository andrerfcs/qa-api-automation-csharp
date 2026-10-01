using QaApiAutomation.Tests.Models;
using RestSharp;

namespace QaApiAutomation.Tests.Clients;

public class UsersApiClient
{
    private readonly RestClient _client;

    public UsersApiClient(string baseUrl)
    {
        _client = new RestClient(baseUrl);
    }

    public async Task<RestResponse> ObterUsersAsync(string endpoint)
    {
        var request = new RestRequest(endpoint, Method.Get);

        return await _client.ExecuteAsync(request);
    }

    public async Task<RestResponse> CriarUserAsync(string endpoint, User user)
    {
        var request = new RestRequest(endpoint, Method.Post);
        request.AddJsonBody(user);

        return await _client.ExecuteAsync(request);
    }

    public async Task<RestResponse> AtualizarUserAsync(string endpoint, User user)
    {
        var request = new RestRequest(endpoint, Method.Put);
        request.AddJsonBody(user);

        return await _client.ExecuteAsync(request);
    }

    public async Task<RestResponse> ExcluirUserAsync(string endpoint)
    {
        var request = new RestRequest(endpoint, Method.Delete);

        return await _client.ExecuteAsync(request);
    }
}