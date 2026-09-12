using QaApiAutomation.Tests.Models;
using RestSharp;

namespace QaApiAutomation.Tests.Clients;

public class BooksApiClient
{
    private readonly RestClient _client = new("https://fakerestapi.azurewebsites.net");

    public async Task<RestResponse> ObterLivrosAsync(string endpoint)
    {
        var request = new RestRequest(endpoint, Method.Get);

        return await _client.ExecuteAsync(request);
    }

    public async Task<RestResponse> CriarLivroAsync(string endpoint, Book livro)
    {
        var request = new RestRequest(endpoint, Method.Post);
        request.AddJsonBody(livro);

        return await _client.ExecuteAsync(request);
    }

    public async Task<RestResponse> AtualizarLivroAsync(string endpoint, Book livro)
    {
        var request = new RestRequest(endpoint, Method.Put);
        request.AddJsonBody(livro);

        return await _client.ExecuteAsync(request);
    }

    public async Task<RestResponse> ExcluirLivroAsync(string endpoint)
    {
        var request = new RestRequest(endpoint, Method.Delete);

        return await _client.ExecuteAsync(request);
    }
}
