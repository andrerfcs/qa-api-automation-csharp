using QaApiAutomation.Tests.Models;
using RestSharp;

namespace QaApiAutomation.Tests.Clients;

public class CoverPhotosApiClient
{
    private readonly RestClient _client;

    public CoverPhotosApiClient(string baseUrl)
    {
        _client = new RestClient(baseUrl);
    }

    public async Task<RestResponse> ObterCoverPhotosAsync(string endpoint)
    {
        var request = new RestRequest(endpoint, Method.Get);

        return await _client.ExecuteAsync(request);
    }

    public async Task<RestResponse> CriarCoverPhotoAsync(string endpoint, CoverPhoto coverPhoto)
    {
        var request = new RestRequest(endpoint, Method.Post);
        request.AddJsonBody(coverPhoto);

        return await _client.ExecuteAsync(request);
    }

    public async Task<RestResponse> AtualizarCoverPhotoAsync(string endpoint, CoverPhoto coverPhoto)
    {
        var request = new RestRequest(endpoint, Method.Put);
        request.AddJsonBody(coverPhoto);

        return await _client.ExecuteAsync(request);
    }

    public async Task<RestResponse> ExcluirCoverPhotoAsync(string endpoint)
    {
        var request = new RestRequest(endpoint, Method.Delete);

        return await _client.ExecuteAsync(request);
    }
}