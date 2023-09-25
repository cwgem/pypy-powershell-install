function Read-PyPyInstallerConfig {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $ConfigFile = "$env:USERPROFILE\.pypy_installer_config.json"
    )

    if( -not  ( Test-Path -LiteralPath $ConfigFile ) ) {
        Write-Warning -Message "Config file ${ConfigFile} not found, using defaults"
        return Import-PyPyInstallerDefaultConfig
    }

    return Get-Content $ConfigFile | ConvertFrom-Json
}

function Import-PyPyInstallerDefaultConfig {
    return @{
        RootPath = "$env:USERPROFILE\.pypy_installer"
    }
}

function Compare-PyPyVersion {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $CurrentVersion,

        [Parameter()]
        [string]
        $PossibleCurrentVersion
    )

    $ReturnVersion = if( [version]$CurrentVersion -gt [version]$PossibleCurrentVersion ) { $false } else { $true }
    return $ReturnVersion
}