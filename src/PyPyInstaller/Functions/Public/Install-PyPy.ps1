<#
.SYNOPSIS
Install a specific PyPy version
.DESCRIPTION
Install a PyPy Version. The destination will be the
root path in the configuration file.
.EXAMPLE
PS> Install-PyPy
.PARAMETER PythonVersions
The version of Python to install
#>
function Install-PyPy {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string[]]
        [Alias('python_version')]
        $PythonVersions,

        [Parameter()]
        [bool]
        $AddRegistryEntries = $true
    )
    begin {
        . $PSScriptRoot\..\Private\Get-PyPyDownloadAndExtract.ps1
        . $PSScriptRoot\..\Private\Utility.ps1

        $PyPyInstallerConfig = Read-PyPyInstallerConfig
        $PyPyVersionInfo = Get-Content -Path "$( $PyPyInstallerConfig.RootPath )\versions.json" | ConvertFrom-Json

        $VersionReturn = New-Object Collections.Generic.List[object]

        if( $AddRegistryEntries ) {
            $PythonVersionComparison = [ordered] @{}
        }
    }
    process {
        foreach ( $PythonVersion in $PythonVersions ) {
            $VersionInfo = $PyPyVersionInfo | Where-Object -FilterScript {  $PSItem.python_version -eq $PythonVersion }
            Get-PyPyDownloadAndExtract -PyPyVersionInfo $VersionInfo
            $VersionReturn.Add($VersionInfo)

            if( $AddRegistryEntries ) {
                $ParsedPythonVersion = [version]$VersionInfo.python_version
                $PythonMajorMinor = "$( $ParsedPythonVersion.Major ).$( $ParsedPythonVersion.Minor )"

                if ( -not $PythonVersionComparison.Contains( $PythonMajorMinor ) ) {
                    $PythonVersionComparison[$PythonMajorMinor] = $VersionInfo
                }
                else {
                    if ( $ParsedPythonVersion -gt [version]$PythonVersions[$PythonMajorMinor].python_version ){
                        $PythonVersionComparison[$PythonMajorMinor] = $VersionInfo
                    }
                }
            }
        }
    }
    end {
        if ( $AddRegistryEntries ) {
            $PythonVersionComparison.Values | Update-PyPyReferences
        }
        return $VersionReturn
    }
}