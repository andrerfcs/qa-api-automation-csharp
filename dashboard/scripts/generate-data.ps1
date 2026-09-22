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
$unitTestsById = @{}
foreach ($unitTest in @($trx.TestRun.TestDefinitions.UnitTest)) {
    $unitTestsById[[string]$unitTest.id] = $unitTest
}

$resultsByFeature = @{}
foreach ($result in $results) {
    $unitTest = $unitTestsById[[string]$result.testId]
    if ($null -eq $unitTest) {
        continue
    }

    $className = [string]$unitTest.TestMethod.className
    $featureClassName = ($className -split '\.')[-1]
    if ($featureClassName -notmatch 'Feature$') {
        continue
    }

    $featureName = $featureClassName.Substring(0, $featureClassName.Length - 'Feature'.Length)
    if (-not $resultsByFeature.ContainsKey($featureName)) {
        $resultsByFeature[$featureName] = New-Object System.Collections.Generic.List[object]
    }

    $resultsByFeature[$featureName].Add($result)
}

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
    $featureName = ($lines | Where-Object { $_ -match '^Feature:\s*(.+)$' } | ForEach-Object { $Matches[1].Trim() } | Select-Object -First 1)
    $scenarioObjects = @()
    $currentScenario = $null
    $inExamples = $false
    $exampleHeaders = @()
    $exampleRows = New-Object System.Collections.Generic.List[object]

    foreach ($line in $lines) {
        if ($line -match '^\s*Scenario(?: Outline)?:\s*(.+)$') {
            if ($null -ne $currentScenario) {
                $examplesData = if ($exampleHeaders.Count -gt 0) { [pscustomobject]@{ headers = @($exampleHeaders); rows = @($exampleRows) } } else { $null }
                $scenarioObjects += [pscustomobject]@{
                    name = $currentScenario.name
                    feature = $currentScenario.feature
                    method = $currentScenario.method
                    route = $currentScenario.route
                    steps = @($currentScenario.steps)
                    examples = $examplesData
                }
            }

            $currentScenario = [pscustomobject]@{
                name = $Matches[1].Trim()
                feature = $featureName
                method = $null
                route = $null
                steps = @()
            }
            $inExamples = $false
            $exampleHeaders = @()
            $exampleRows = New-Object System.Collections.Generic.List[object]
            continue
        }

        if ($null -eq $currentScenario) {
            continue
        }

        if ($line -match '^\s*Examples:\s*$') {
            $inExamples = $true
            continue
        }

        if ($inExamples -and $line -match '^\s*\|(.+)\|\s*$') {
            $values = @($Matches[1].Split('|') | ForEach-Object { $_.Trim() })
            if ($exampleHeaders.Count -eq 0) {
                $exampleHeaders = $values
            } else {
                $row = [ordered]@{}
                for ($index = 0; $index -lt $exampleHeaders.Count; $index++) {
                    $row[$exampleHeaders[$index]] = if ($index -lt $values.Count) { $values[$index] } else { "" }
                }
                $exampleRows += $row
            }
            continue
        }

        if ($line -match '^\s*(Given|When|Then|And|But)\s+(.+)$') {
            $keyword = $Matches[1]
            $stepText = $Matches[2].Trim()
            $currentScenario.steps += [pscustomobject]@{ keyword = $keyword; text = $stepText }
            if ($keyword -eq "When" -and $stepText -match '\b(GET|POST|PUT|DELETE)\b') {
                $currentScenario.method = $Matches[1]
                if ($stepText -match '"([^\"]+)"') {
                    $currentScenario.route = $Matches[1]
                }
            }
        }
    }

    if ($null -ne $currentScenario) {
        $examplesData = if ($exampleHeaders.Count -gt 0) { [pscustomobject]@{ headers = @($exampleHeaders); rows = @($exampleRows) } } else { $null }
        $scenarioObjects += [pscustomobject]@{
            name = $currentScenario.name
            feature = $currentScenario.feature
            method = $currentScenario.method
            route = $currentScenario.route
            steps = @($currentScenario.steps)
            examples = $examplesData
        }
    }

    $featureResults = if ($resultsByFeature.ContainsKey($featureName)) { $resultsByFeature[$featureName].ToArray() } else { @() }
    $featurePassed = @($featureResults | Where-Object { $_.outcome -eq "Passed" }).Count
    $featureFailed = @($featureResults | Where-Object { $_.outcome -eq "Failed" }).Count
    $featureSkipped = @($featureResults | Where-Object { $_.outcome -in @("Skipped", "NotExecuted") }).Count

    [ordered]@{
        name = $featureName
        file = $file.Name
        total = $scenarioObjects.Count
        executed = $featureResults.Count
        passed = $featurePassed
        failed = $featureFailed
        skipped = $featureSkipped
        status = if ($featureFailed -gt 0) { "Failed" } elseif ($featureSkipped -gt 0) { "Skipped" } else { "Passed" }
        scenarios = @($scenarioObjects)
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
