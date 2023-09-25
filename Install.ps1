<#
.SYNOPSIS
Install PyPyInstaller Powershell module
.DESCRIPTION
Install PyPyInstaller Powershell module
.PARAMETER SetupOnly
If set, it will skip download and installation of the
latest PyPyInstaller module
.PARAMETER RootPath
Root directory for PyPy installer. Depending on the
target you may need to run with administrative
privileges
.PARAMETER UpdateMirrorList
If set, the installer will also update the PyPy
mirror list used to pull version information
from
#>

param (
    [Parameter()]
    [switch]
    $SetupOnly,

    [Parameter()]
    [switch]
    $UpdateMirrorList,

    [Parameter()]
    [System.IO.DirectoryInfo]
    $RootPath = "$env:USERPROFILE\.pypy_installer"
)

if(! $SetupOnly ) {
    Write-Information "Pulling latest version from GitHub"
    # https://github.com/PowerShell/PowerShellGetv2/blob/3b38eec8742d6b6f26cf0f010e0dd95691ed5ade/src/PowerShellGet/private/modulefile/PartOne.ps1
    # So I don't have to worry if users have PowerShellGet with PSGetPath defined

    # Copyright (c) Microsoft Corporation.

    # MIT License

    # Permission is hereby granted, free of charge, to any person obtaining a copy
    # of this software and associated documentation files (the "Software"), to deal
    # in the Software without restriction, including without limitation the rights
    # to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    # copies of the Software, and to permit persons to whom the Software is
    # furnished to do so, subject to the following conditions:

    # The above copyright notice and this permission notice shall be included in all
    # copies or substantial portions of the Software.

    # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    # IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    # FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    # AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    # LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    # OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    # SOFTWARE.
    $script:IsInbox = $PSHOME.EndsWith('\WindowsPowerShell\v1.0', [System.StringComparison]::OrdinalIgnoreCase)

    try {
        $script:MyDocumentsFolderPath = [Environment]::GetFolderPath("MyDocuments")
    }
    catch {
        $script:MyDocumentsFolderPath = $null
    }

    if ($script:IsInbox) {
        $script:MyDocumentsPSPath = if ($script:MyDocumentsFolderPath) {
            Microsoft.PowerShell.Management\Join-Path -Path $script:MyDocumentsFolderPath -ChildPath "WindowsPowerShell"
        }
        else {
            Microsoft.PowerShell.Management\Join-Path -Path $env:USERPROFILE -ChildPath "Documents\WindowsPowerShell"
        }
    }
    elseif ($script:IsCoreCLR) {
        $script:MyDocumentsPSPath = if ($script:MyDocumentsFolderPath) {
            Microsoft.PowerShell.Management\Join-Path -Path $script:MyDocumentsFolderPath -ChildPath 'PowerShell'
        }
        else {
            Microsoft.PowerShell.Management\Join-Path -Path $HOME -ChildPath "Documents\PowerShell"
        }
    }

    $script:MyDocumentsModulesPath = Microsoft.PowerShell.Management\Join-Path -Path $script:MyDocumentsPSPath -ChildPath 'Modules'

    Write-Information 'Downloading latest release asset from GitHub'
    $ReleaseData = Invoke-RestMethod -Uri https://api.github.com/repos/cwgem/pypy-powershell-install/releases/latest
    $ReleaseUrl = $ReleaseData.assets | Where-Object -FilterScript { $_.name -EQ "PyPyInstaller-$( $ReleaseData.tag_name ).zip" } | Select-Object -ExpandProperty browser_download_url
    Invoke-WebRequest -Uri $ReleaseUrl -OutFile "$env:temp\PyPyInstaller.zip"

    New-Item -ItemType Directory -Force $script:MyDocumentsModulesPath
    Expand-Archive -LiteralPath "$env:temp\PyPyInstaller.zip" -DestinationPath "${script:MyDocumentsModulesPath}" -Force
}

if( $UpdateMirrorList ) {
    Invoke-WebRequest -Uri https://buildbot.pypy.org/mirror/versions.json | Select-Object -ExpandProperty Content | Out-File "${RootPath}\versions.json"
}

if( -not ( Test-Path "$env:USERPROFILE\.pypy_installer_config.json" ) ) {
    $DefaultConfig = @{
        RootPath = $RootPath.FullName
    }
    $DefaultConfig | ConvertTo-Json | Out-File "$env:USERPROFILE\.pypy_installer_config.json"
}
New-Item -ItemType Directory -Path $RootPath.FullName -Force
Import-Module PyPyInstaller -Force

Write-Information 'Setup Finished'