param(
    [string]$TrxPath = "artifacts/test-results/test-results.trx",
    [string]$OutputPath = "reports/execution-report.html"
)

$ErrorActionPreference = "Stop"
$root = (Get-Location).Path
$resolvedTrxPath = if ([System.IO.Path]::IsPathRooted($TrxPath)) { $TrxPath } else { Join-Path $root $TrxPath }
$resolvedOutputPath = if ([System.IO.Path]::IsPathRooted($OutputPath)) { $OutputPath } else { Join-Path $root $OutputPath }

if (-not (Test-Path -LiteralPath $resolvedTrxPath -PathType Leaf)) {
    throw "TRX file not found: $resolvedTrxPath"
}

[xml]$trx = New-Object System.Xml.XmlDocument
$trx.PreserveWhitespace = $false
$trx.Load($resolvedTrxPath)

$namespaceManager = New-Object System.Xml.XmlNamespaceManager($trx.NameTable)
$namespaceManager.AddNamespace("trx", "http://microsoft.com/schemas/VisualStudio/TeamTest/2010")

function ConvertTo-HtmlEncoded {
    param([AllowNull()][object]$Value)

    if ($null -eq $Value) {
        return ""
    }

    return [System.Net.WebUtility]::HtmlEncode([string]$Value)
}

function Format-Duration {
    param([TimeSpan]$Duration)

    $hours = [math]::Floor($Duration.TotalHours).ToString("00", [Globalization.CultureInfo]::InvariantCulture)
    $minutes = $Duration.Minutes.ToString("00", [Globalization.CultureInfo]::InvariantCulture)
    $seconds = $Duration.Seconds.ToString("00", [Globalization.CultureInfo]::InvariantCulture)
    $milliseconds = $Duration.Milliseconds.ToString("000", [Globalization.CultureInfo]::InvariantCulture)
    return "$hours`:$minutes`:$seconds.$milliseconds"
}

$testDefinitions = @{}
$definitionNodes = $trx.SelectNodes("/trx:TestRun/trx:TestDefinitions/trx:UnitTest", $namespaceManager)
foreach ($definition in $definitionNodes) {
    $method = $definition.SelectSingleNode(".//trx:TestMethod", $namespaceManager)
    $className = if ($null -ne $method) { $method.GetAttribute("className") } else { "" }
    $feature = "Uncategorized"

    if (-not [string]::IsNullOrWhiteSpace($className)) {
        $classParts = $className.Split('.')
        $classNameOnly = $classParts[$classParts.Length - 1]
        if ($classNameOnly.EndsWith("Feature", [StringComparison]::OrdinalIgnoreCase)) {
            $feature = $classNameOnly.Substring(0, $classNameOnly.Length - "Feature".Length)
        } else {
            $feature = $classNameOnly
        }
    }

    $testDefinitions[$definition.GetAttribute("id")] = $feature
}

$featureGroups = @{}
$testRecords = New-Object System.Collections.Generic.List[object]
$passedCount = 0
$failedCount = 0
$skippedCount = 0
$totalDuration = [TimeSpan]::Zero
$resultNodes = $trx.SelectNodes("/trx:TestRun/trx:Results/trx:UnitTestResult", $namespaceManager)

foreach ($result in $resultNodes) {
    $testId = $result.GetAttribute("testId")
    $feature = if ($testDefinitions.ContainsKey($testId)) { $testDefinitions[$testId] } else { "Uncategorized" }
    $outcome = $result.GetAttribute("outcome")
    $testName = $result.GetAttribute("testName")
    $duration = [TimeSpan]::Zero
    [void][TimeSpan]::TryParse($result.GetAttribute("duration"), [ref]$duration)
    $totalDuration = $totalDuration.Add($duration)

    switch ($outcome.ToLowerInvariant()) {
        { $_ -in @("passed", "pass") } { $passedCount++; $outcomeClass = "passed"; $outcomeLabel = "Passed"; break }
        { $_ -in @("failed", "fail", "error") } { $failedCount++; $outcomeClass = "failed"; $outcomeLabel = "Failed"; break }
        { $_ -in @("skipped", "notexecuted", "not executed", "notrunnable") } { $skippedCount++; $outcomeClass = "skipped"; $outcomeLabel = "Skipped / not executed"; break }
        default { $skippedCount++; $outcomeClass = "skipped"; $outcomeLabel = if ([string]::IsNullOrWhiteSpace($outcome)) { "Not executed" } else { $outcome }; break }
    }

    $stdoutNode = $result.SelectSingleNode("./trx:Output/trx:StdOut", $namespaceManager)
    $bddSteps = New-Object System.Collections.Generic.List[string]
    if ($null -ne $stdoutNode) {
        $stdoutLines = ([string]$stdoutNode.InnerText).Split([char[]]@("`r", "`n"), [StringSplitOptions]::RemoveEmptyEntries)
        foreach ($line in $stdoutLines) {
            $step = $line.Trim()
            $firstSpace = $step.IndexOf(' ')
            if ($firstSpace -gt 0 -and @("Given", "When", "Then", "And", "But") -contains $step.Substring(0, $firstSpace)) {
                $bddSteps.Add($step)
            }
        }
    }

    $errorNode = $result.SelectSingleNode("./trx:Output/trx:ErrorInfo", $namespaceManager)
    $errorMessage = ""
    $stackTrace = ""
    if ($null -ne $errorNode) {
        $messageNode = $errorNode.SelectSingleNode("./trx:Message", $namespaceManager)
        $stackNode = $errorNode.SelectSingleNode("./trx:StackTrace", $namespaceManager)
        if ($null -ne $messageNode) { $errorMessage = $messageNode.InnerText.Trim() }
        if ($null -ne $stackNode) { $stackTrace = $stackNode.InnerText.Trim() }
    }

    $record = [pscustomobject]@{
        Feature = $feature
        Name = $testName
        Outcome = $outcomeLabel
        OutcomeClass = $outcomeClass
        Duration = Format-Duration $duration
        Steps = $bddSteps
        ErrorMessage = $errorMessage
        StackTrace = $stackTrace
    }
    $testRecords.Add($record)

    if (-not $featureGroups.ContainsKey($feature)) {
        $featureGroups[$feature] = New-Object System.Collections.Generic.List[object]
    }
    $featureGroups[$feature].Add($record)
}

$totalCount = $testRecords.Count
$successPercentage = if ($totalCount -gt 0) { [math]::Round(($passedCount / $totalCount) * 100, 1) } else { 0 }
$timesNode = $trx.SelectSingleNode("/trx:TestRun/trx:Times", $namespaceManager)
$executionTime = Get-Date
if ($null -ne $timesNode -and -not [string]::IsNullOrWhiteSpace($timesNode.GetAttribute("finish"))) {
    $parsedExecutionTime = [DateTimeOffset]::MinValue
    if ([DateTimeOffset]::TryParse($timesNode.GetAttribute("finish"), [Globalization.CultureInfo]::InvariantCulture, [Globalization.DateTimeStyles]::RoundtripKind, [ref]$parsedExecutionTime)) {
        $executionTime = $parsedExecutionTime.LocalDateTime
    }
}
$executionDuration = $totalDuration
if ($null -ne $timesNode) {
    $startTime = [DateTimeOffset]::MinValue
    $finishTime = [DateTimeOffset]::MinValue
    if ([DateTimeOffset]::TryParse($timesNode.GetAttribute("start"), [Globalization.CultureInfo]::InvariantCulture, [Globalization.DateTimeStyles]::RoundtripKind, [ref]$startTime) -and
        [DateTimeOffset]::TryParse($timesNode.GetAttribute("finish"), [Globalization.CultureInfo]::InvariantCulture, [Globalization.DateTimeStyles]::RoundtripKind, [ref]$finishTime)) {
        $executionDuration = $finishTime - $startTime
    }
}

$featureCards = New-Object System.Text.StringBuilder
foreach ($featureName in ($featureGroups.Keys | Sort-Object)) {
    $records = $featureGroups[$featureName]
    $featurePassed = @($records | Where-Object OutcomeClass -eq "passed").Count
    $featureFailed = @($records | Where-Object OutcomeClass -eq "failed").Count
    $featureSuccess = if ($records.Count -gt 0) { [math]::Round(($featurePassed / $records.Count) * 100, 1) } else { 0 }
    $featureCards.AppendLine("<article class=`"feature-card`"><div class=`"feature-heading`"><h3>$(ConvertTo-HtmlEncoded $featureName)</h3><span>$(ConvertTo-HtmlEncoded $records.Count) executions</span></div><div class=`"feature-stats`"><span><strong>$(ConvertTo-HtmlEncoded $featurePassed)</strong> passed</span><span><strong>$(ConvertTo-HtmlEncoded $featureFailed)</strong> failed</span><span><strong>$(ConvertTo-HtmlEncoded $featureSuccess)%</strong> success</span></div></article>") | Out-Null
}

$executionItems = New-Object System.Text.StringBuilder
foreach ($record in $testRecords) {
    $encodedFeature = ConvertTo-HtmlEncoded $record.Feature
    $encodedName = ConvertTo-HtmlEncoded $record.Name
    $encodedOutcome = ConvertTo-HtmlEncoded $record.Outcome
    $encodedDuration = ConvertTo-HtmlEncoded $record.Duration
    $executionItems.AppendLine("<details class=`"execution-item $($record.OutcomeClass)`"><summary><span class=`"execution-feature`">$encodedFeature</span><span class=`"execution-name`">$encodedName</span><span class=`"outcome $($record.OutcomeClass)`">$encodedOutcome</span><time>$encodedDuration</time></summary><div class=`"execution-details`">") | Out-Null

    if ($record.Steps.Count -gt 0) {
        $executionItems.AppendLine("<h4>BDD steps</h4><ol class=`"bdd-steps`">") | Out-Null
        foreach ($step in $record.Steps) {
            $executionItems.AppendLine("<li>$(ConvertTo-HtmlEncoded $step)</li>") | Out-Null
        }
        $executionItems.AppendLine("</ol>") | Out-Null
    }

    if ($record.OutcomeClass -eq "failed" -and (-not [string]::IsNullOrWhiteSpace($record.ErrorMessage) -or -not [string]::IsNullOrWhiteSpace($record.StackTrace))) {
        $executionItems.AppendLine("<section class=`"failure-info`"><h4>Failure details</h4>") | Out-Null
        if (-not [string]::IsNullOrWhiteSpace($record.ErrorMessage)) {
            $executionItems.AppendLine("<p>$(ConvertTo-HtmlEncoded $record.ErrorMessage)</p>") | Out-Null
        }
        if (-not [string]::IsNullOrWhiteSpace($record.StackTrace)) {
            $executionItems.AppendLine("<pre>$(ConvertTo-HtmlEncoded $record.StackTrace)</pre>") | Out-Null
        }
        $executionItems.AppendLine("</section>") | Out-Null
    }

    if ($record.Steps.Count -eq 0 -and [string]::IsNullOrWhiteSpace($record.ErrorMessage) -and [string]::IsNullOrWhiteSpace($record.StackTrace)) {
        $executionItems.AppendLine("<p class=`"no-details`">No BDD steps or failure details were recorded for this execution.</p>") | Out-Null
    }
    $executionItems.AppendLine("</div></details>") | Out-Null
}

$emptyState = if ($totalCount -eq 0) { "<p class=`"empty-state`">No test executions were found in this TRX file.</p>" } else { "" }
$html = @"
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Execution Report</title>
  <style>
    :root { color-scheme: light; --page: #f5f5f1; --surface: #fff; --ink: #2d3731; --muted: #6c766f; --line: #e2e6e0; --green: #477458; --green-soft: #edf4ee; --red: #b64943; --red-soft: #fbefed; --amber: #997024; --amber-soft: #f7f2e7; --shadow: 0 2px 9px rgba(35, 49, 39, .045); }
    * { box-sizing: border-box; }
    body { margin: 0; color: var(--ink); background: var(--page); font: 14px/1.5 "Segoe UI", Arial, sans-serif; }
    main { width: min(1180px, calc(100% - 40px)); margin: 0 auto; padding: 28px 0 36px; }
    header { display: flex; justify-content: space-between; align-items: flex-end; gap: 20px; padding-bottom: 18px; border-bottom: 1px solid var(--line); }
    .eyebrow { margin: 0 0 4px; color: var(--green); font-size: 11px; font-weight: 700; letter-spacing: .08em; text-transform: uppercase; }
    h1 { margin: 0; font-size: 28px; line-height: 1.2; }
    .subtitle { margin: 6px 0 0; color: var(--muted); }
    .run-time { text-align: right; color: var(--muted); font-size: 12px; }
    .run-time strong { display: block; color: var(--ink); font-size: 14px; font-weight: 600; }
    h2 { margin: 23px 0 10px; font-size: 18px; }
    .summary { display: grid; grid-template-columns: repeat(6, minmax(0, 1fr)); gap: 9px; margin-top: 18px; }
    .summary-card, .feature-card, .executions { background: var(--surface); border: 1px solid var(--line); border-radius: 7px; box-shadow: var(--shadow); }
    .summary-card { min-height: 82px; padding: 12px 14px; }
    .summary-card span { display: block; color: var(--muted); font-size: 11px; font-weight: 600; }
    .summary-card strong { display: block; margin-top: 5px; font-size: 22px; line-height: 1.1; }
    .summary-card.passed strong { color: var(--green); }
    .summary-card.failed strong { color: var(--red); }
    .feature-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(210px, 1fr)); gap: 9px; }
    .feature-card { padding: 13px 14px; }
    .feature-heading { display: flex; justify-content: space-between; align-items: baseline; gap: 8px; }
    .feature-heading h3 { margin: 0; font-size: 15px; }
    .feature-heading span { color: var(--muted); font-size: 11px; white-space: nowrap; }
    .feature-stats { display: flex; flex-wrap: wrap; gap: 8px 14px; margin-top: 12px; color: var(--muted); font-size: 11px; }
    .feature-stats strong { color: var(--ink); font-size: 13px; }
    .feature-stats span:first-child strong { color: var(--green); }
    .feature-stats span:nth-child(2) strong { color: var(--red); }
    .executions { overflow: hidden; }
    .execution-item { border-bottom: 1px solid var(--line); }
    .execution-item:last-child { border-bottom: 0; }
    .execution-item summary { display: grid; grid-template-columns: 130px minmax(0, 1fr) 92px 110px; align-items: center; gap: 12px; min-height: 48px; padding: 8px 14px; cursor: pointer; list-style: none; }
    .execution-item summary::-webkit-details-marker { display: none; }
    .execution-item summary::before { position: absolute; margin-left: -3px; color: #888f89; content: "+"; transform: translateX(-9px); }
    .execution-item[open] summary::before { content: "-"; }
    .execution-item summary:hover { background: #fafbf9; }
    .execution-feature { color: var(--muted); font-size: 12px; }
    .execution-name { min-width: 0; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; font-weight: 550; }
    .outcome { justify-self: start; padding: 2px 7px; border-radius: 99px; font-size: 11px; font-weight: 650; }
    .outcome.passed { color: var(--green); background: var(--green-soft); }
    .outcome.failed { color: var(--red); background: var(--red-soft); }
    .outcome.skipped { color: var(--amber); background: var(--amber-soft); }
    time { color: var(--muted); font-size: 12px; font-variant-numeric: tabular-nums; text-align: right; }
    .execution-details { padding: 0 16px 14px 34px; }
    .execution-details h4 { margin: 8px 0 5px; font-size: 12px; }
    .bdd-steps { margin: 0; padding-left: 20px; color: #48544c; font-size: 12px; }
    .bdd-steps li { padding: 2px 0; }
    .failure-info { margin-top: 10px; padding: 10px 12px; border-left: 3px solid var(--red); background: var(--red-soft); }
    .failure-info h4 { margin-top: 0; color: var(--red); }
    .failure-info p { margin: 4px 0; white-space: pre-wrap; }
    .failure-info pre { max-height: 320px; overflow: auto; margin: 8px 0 0; color: #543b39; font: 11px/1.45 Consolas, monospace; white-space: pre-wrap; overflow-wrap: anywhere; }
    .no-details, .empty-state { margin: 8px 0; color: var(--muted); font-size: 12px; }
    footer { margin-top: 18px; color: var(--muted); font-size: 11px; text-align: center; }
    @media (max-width: 850px) { .summary { grid-template-columns: repeat(3, minmax(0, 1fr)); } }
    @media (max-width: 620px) { main { width: calc(100% - 24px); padding-top: 18px; } header { align-items: flex-start; flex-direction: column; gap: 10px; } .run-time { text-align: left; } .summary { grid-template-columns: repeat(2, minmax(0, 1fr)); } .execution-item summary { grid-template-columns: minmax(0, 1fr) auto; gap: 4px 10px; padding: 10px 14px 10px 24px; } .execution-feature { grid-column: 1; } .execution-name { grid-column: 1; grid-row: 2; white-space: normal; } .outcome { grid-column: 2; grid-row: 1; } time { grid-column: 2; grid-row: 2; } .execution-details { padding-left: 24px; } }
    @media (prefers-reduced-motion: reduce) { *, *::before, *::after { scroll-behavior: auto !important; transition-duration: .01ms !important; } }
  </style>
</head>
<body>
  <main>
    <header>
      <div><p class="eyebrow">Test Automation</p><h1>Execution Report</h1><p class="subtitle">NUnit and Reqnroll test run results</p></div>
      <div class="run-time"><span>Execution date and time</span><strong>$(ConvertTo-HtmlEncoded $executionTime.ToString("dd MMM yyyy, HH:mm:ss", [Globalization.CultureInfo]::InvariantCulture))</strong></div>
    </header>
    <section class="summary" aria-label="Execution summary">
      <article class="summary-card"><span>Total tests</span><strong>$(ConvertTo-HtmlEncoded $totalCount)</strong></article>
      <article class="summary-card passed"><span>Passed</span><strong>$(ConvertTo-HtmlEncoded $passedCount)</strong></article>
      <article class="summary-card failed"><span>Failed</span><strong>$(ConvertTo-HtmlEncoded $failedCount)</strong></article>
      <article class="summary-card"><span>Skipped / not executed</span><strong>$(ConvertTo-HtmlEncoded $skippedCount)</strong></article>
      <article class="summary-card"><span>Success rate</span><strong>$(ConvertTo-HtmlEncoded $successPercentage)%</strong></article>
      <article class="summary-card"><span>Total duration</span><strong>$(ConvertTo-HtmlEncoded (Format-Duration $executionDuration))</strong></article>
    </section>
    <section aria-labelledby="features-title"><h2 id="features-title">Executions by Feature</h2><div class="feature-grid">$($featureCards.ToString())</div></section>
    <section aria-labelledby="executions-title"><h2 id="executions-title">Individual test executions</h2><div class="executions">$emptyState$($executionItems.ToString())</div></section>
    <footer>Execution Report generated from TRX test results</footer>
  </main>
</body>
</html>
"@

$outputDirectory = Split-Path -Parent $resolvedOutputPath
New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null
[System.IO.File]::WriteAllText($resolvedOutputPath, $html, [System.Text.UTF8Encoding]::new($false))
Write-Output "Execution report generated: $resolvedOutputPath"
