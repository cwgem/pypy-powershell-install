function Set-PyPyPathEntry {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $InstallPath
    )

    . "$PSScriptRoot\..\..\Wrappers\PathEnvironment.ps1"

    $CurrentPath = Get-PyPyPathEnvironmentVariable
    [System.Collections.ArrayList] $SplitPath = $CurrentPath -split ";"

    if ( $SplitPath -contains $InstallPath ) {
        Write-Warning -Message "Folder $InstallPath already exists in PATH"
    }
    else {
        $SplitPath.Add($InstallPath)
        Set-PyPyPathEnvironmentVariable -NewPath ( $SplitPath | Join-String -Separator ';' )
    }
}