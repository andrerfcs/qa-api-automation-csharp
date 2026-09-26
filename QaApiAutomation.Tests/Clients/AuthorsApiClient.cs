using QaApiAutomation.Tests.Models;
using RestSharp;

namespace QaApiAutomation.Tests.Clients;

public class AuthorsApiClient
{
    private readonly RestClient _client;

    public AuthorsApiClient(string baseUrl)
    {
        _client = new RestClient(baseUrl);
    }

    public async Task<RestResponse> ObterAutoresAsync(string endpoint)
    {
        var request = new RestRequest(endpoint, Method.Get);

        return await _client.ExecuteAsync(request);
    }

    public async Task<RestResponse> ObterAutoresPorLivroAsync(int idBook)
    {
        var endpoint = $"/api/v1/Authors/authors/books/{idBook}";
        var request = new RestRequest(endpoint, Method.Get);

        return await _client.ExecuteAsync(request);
    }

    public async Task<RestResponse> CriarAutorAsync(string endpoint, Author autor)
    {
        var request = new RestRequest(endpoint, Method.Post);
        request.AddJsonBody(autor);

        return await _client.ExecuteAsync(request);
    }

    public async Task<RestResponse> AtualizarAutorAsync(string endpoint, Author autor)
    {
        var request = new RestRequest(endpoint, Method.Put);
        request.AddJsonBody(autor);

        return await _client.ExecuteAsync(request);
    }

    public async Task<RestResponse> ExcluirAutorAsync(string endpoint)
    {
        var request = new RestRequest(endpoint, Method.Delete);

        return await _client.ExecuteAsync(request);
    }
}
