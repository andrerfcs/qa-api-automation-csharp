param(
    [string]$Solution = "QaApiAutomation.sln",
    [string]$ResultsDirectory = "artifacts/test-results",
    [string]$OutputFile = "dashboard/data/results.json"
)

$ErrorActionPreference = "Stop"
$root = (Get-Location).Path
$resultsPath = Join-Path $root $ResultsDirectory
$outputPath = Join-Path $root $OutputFile

New-Item -ItemType Directory -Force -Path $resultsPath, (Split-Path $outputPath) | Out-Null

& dotnet test $Solution --logger "trx;LogFileName=test-results.trx" --results-directory $resultsPath
$testExitCode = $LASTEXITCODE

$trxPath = Join-Path $resultsPath "test-results.trx"
if (-not (Test-Path $trxPath)) {
    throw "Arquivo TRX não encontrado em $trxPath"
}

[xml]$trx = Get-Content -Raw -Path $trxPath
$results = @($trx.TestRun.Results.UnitTestResult)
$summary = [ordered]@{
    total = $results.Count
    passed = @($results | Where-Object { $_.outcome -eq "Passed" }).Count
    failed = @($results | Where-Object { $_.outcome -eq "Failed" }).Count
    skipped = @($results | Where-Object { $_.outcome -in @("Skipped", "NotExecuted") }).Count
    successRate = if ($results.Count -gt 0) {
        [math]::Round((@($results | Where-Object { $_.outcome -eq "Passed" }).Count / $results.Count) * 100, 2)
    } else { 0 }
}

$duration = [TimeSpan]::Zero
foreach ($result in $results) {
    $parsedDuration = [TimeSpan]::Zero
    if ([TimeSpan]::TryParse([string]$result.duration, [ref]$parsedDuration)) {
        $duration = $duration.Add($parsedDuration)
    }
}

$featureFiles = Get-ChildItem -Path (Join-Path $root "QaApiAutomation.Tests/Features") -Filter "*.feature" -File
$features = foreach ($file in $featureFiles) {
    $lines = [System.IO.File]::ReadAllLines($file.FullName, [System.Text.Encoding]::UTF8)
    $scenarios = foreach ($line in $lines) {
        if ($line -match '^\s*Scenario(?: Outline)?:\s*(.+)$') {
            [ordered]@{ name = $Matches[1].Trim() }
        }
    }

    $featureName = ($lines | Where-Object { $_ -match '^Feature:\s*(.+)$' } | ForEach-Object { $Matches[1].Trim() } | Select-Object -First 1)
    $featurePassed = @($results | Where-Object { $_.outcome -eq "Passed" }).Count
    $featureFailed = @($results | Where-Object { $_.outcome -eq "Failed" }).Count
    $featureSkipped = @($results | Where-Object { $_.outcome -in @("Skipped", "NotExecuted") }).Count

    [ordered]@{
        name = $featureName
        file = $file.Name
        total = @($scenarios).Count
        executed = $results.Count
        passed = $featurePassed
        failed = $featureFailed
        skipped = $featureSkipped
        status = if ($featureFailed -gt 0) { "Failed" } elseif ($featureSkipped -gt 0) { "Skipped" } else { "Passed" }
        scenarios = @($scenarios | ForEach-Object { [ordered]@{ name = $_.name; feature = $featureName; status = "Inventory" } })
    }
}

$status = if ($testExitCode -eq 0 -and $summary.failed -eq 0) { "Passed" } else { "Failed" }
$data = [ordered]@{
    generatedAt = (Get-Date).ToUniversalTime().ToString("o")
    summary = $summary
    execution = [ordered]@{
        status = $status
        lastRun = (Get-Date).ToUniversalTime().ToString("o")
        duration = $duration.ToString()
        resultFile = ($trxPath.Replace($root, "") -replace '^[\\/]+', '')
    }
    automation = [ordered]@{
        features = @($features)
    }
    coverage = [ordered]@{
        automation = "Inventario de features e cenarios"
        code = $null
    }
}

$json = $data | ConvertTo-Json -Depth 8
[System.IO.File]::WriteAllText($outputPath, $json, [System.Text.UTF8Encoding]::new($false))
Write-Host "Dashboard data generated at $outputPath"

if ($testExitCode -ne 0) {
    exit $testExitCode
}
