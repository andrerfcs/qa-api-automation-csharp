using System.Diagnostics;
using OpenTelemetry.Trace;
using QaApiAutomation.Tests.Observability;
using Reqnroll;

namespace QaApiAutomation.Tests.Hooks;

[Binding]
public class TelemetryHooks
{
    private static TracerProvider? _tracerProvider;

    private readonly ScenarioContext _scenarioContext;
    private Activity? _scenarioActivity;

    public TelemetryHooks(ScenarioContext scenarioContext)
    {
        _scenarioContext = scenarioContext;
    }

    [BeforeTestRun]
    public static void BeforeTestRun()
    {
        _tracerProvider = Telemetry.CreateTracerProvider();
    }

    [BeforeScenario]
    public void BeforeScenario()
    {
        _scenarioActivity = Telemetry.ActivitySource.StartActivity(
            $"Scenario: {_scenarioContext.ScenarioInfo.Title}",
            ActivityKind.Internal);

        _scenarioActivity?.SetTag(
            "test.framework",
            "Reqnroll");

        _scenarioActivity?.SetTag(
            "test.name",
            _scenarioContext.ScenarioInfo.Title);
    }

    [AfterScenario]
    public void AfterScenario()
    {
        if (_scenarioActivity is null)
            return;

        if (_scenarioContext.TestError is null)
        {
            _scenarioActivity.SetTag("test.status", "passed");
            _scenarioActivity.SetStatus(ActivityStatusCode.Ok);
        }
        else
        {
            _scenarioActivity.SetTag("test.status", "failed");

            _scenarioActivity.SetTag(
                "error.type",
                _scenarioContext.TestError.GetType().FullName);

            _scenarioActivity.SetTag(
                "error.message",
                _scenarioContext.TestError.Message);

            _scenarioActivity.SetStatus(
                ActivityStatusCode.Error,
                _scenarioContext.TestError.Message);
        }

        _scenarioActivity.Dispose();
    }

    [AfterTestRun]
    public static void AfterTestRun()
    {
        _tracerProvider?.Dispose();
    }
}
