param (
    [String] $Path = ".",
    [String] $Output = "Detailed",
    [String] $OutputFormat = "CoverageGutters",
    [Switch] $CodeCoverage
)

$Configuration = [PesterConfiguration]::Default

$Configuration.Run.Path = $Path
$Configuration.Run.PassThru = $true

$Configuration.Output.Verbosity = $Output

$Configuration.CodeCoverage.Enabled = [bool] $CodeCoverage
$Configuration.CodeCoverage.OutputFormat = $OutputFormat
$Configuration.CodeCoverage.Path = @( "$PSScriptRoot\src\PyPyInstaller\Functions" )
$Configuration.CodeCoverage.OutputPath = "$PSScriptRoot/coverage.xml"
$Configuration.CodeCoverage.CoveragePercentTarget = 90
$Configuration.CodeCoverage.ExcludeTests = $true

$isDirectory = (Get-Item $Path).PSIsContainer
$isTestFile = $Path.EndsWith($Configuration.Run.TestExtension.Value)
if (-not $isDirectory -and -not $isTestFile) {
    & $Path
    return
}

return Invoke-Pester -Configuration $Configuration