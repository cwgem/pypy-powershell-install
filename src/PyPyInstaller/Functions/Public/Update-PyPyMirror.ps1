<#
.SYNOPSIS
Update mirror listing for PyPy releases
.DESCRIPTION
Download a mirror listing for PyPy releases to prevent
continually hitting the mirror for version information
.EXAMPLE
PS> Update-PyPyMirror
#>
function Update-PyPyMirror {
    [CmdletBinding()]
    param ()

    . $PSScriptRoot\..\Private\Utility.ps1
    $PyPyInstallerConfig = Read-PyPyInstallerConfig

    Invoke-WebRequest -Uri "https://buildbot.pypy.org/mirror/versions.json" | Select-Object -ExpandProperty Content | Out-File -FilePath "$($PyPyInstallerConfig.RootPath)\versions.json"
}