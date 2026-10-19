using System.Diagnostics;
using OpenTelemetry;
using OpenTelemetry.Trace;
using OpenTelemetry.Resources;

namespace QaApiAutomation.Tests.Observability;

public static class Telemetry
{
    public const string ServiceName = "QaApiAutomation";

    public static readonly ActivitySource ActivitySource =
        new(ServiceName);

    public static TracerProvider CreateTracerProvider()
    {
        return Sdk.CreateTracerProviderBuilder()
            .SetResourceBuilder(
                ResourceBuilder.CreateDefault()
                    .AddService(ServiceName))
            .AddSource(ServiceName)
            .AddHttpClientInstrumentation()
            .AddConsoleExporter()
            .Build();
    }
}
