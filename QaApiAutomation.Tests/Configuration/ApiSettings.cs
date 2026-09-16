namespace QaApiAutomation.Tests.Configuration;

public static class ApiSettings
{
    private const string DefaultBaseUrl = "https://fakerestapi.azurewebsites.net";
    private const string BaseUrlEnvironmentVariable = "API_BASE_URL";

    public static string BaseUrl
    {
        get
        {
            var configuredBaseUrl = Environment.GetEnvironmentVariable(BaseUrlEnvironmentVariable);

            return string.IsNullOrWhiteSpace(configuredBaseUrl)
                ? DefaultBaseUrl
                : configuredBaseUrl;
        }
    }
}