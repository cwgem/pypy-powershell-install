<#
.SYNOPSIS
Register a PyPY version with the Python Launcher.
.DESCRIPTION
This allows a PyPy installation to be recognized by
the Python Launcher through PEP514 compatible registry
key entries.
.EXAMPLE
PS> Update-PyPyReferences "3.9"
.EXAMPLE
PS> Update-PyPyReferences -ManualParse c:\Path\To\PyPy\Root\Installation\Path
.PARAMETER PythonVersions
The version(s) of Python to register with the launcher.
.PARAMETER ManualParse
Enables addition of non-PyPyInstaller managed PyPy installations through
parsing of sys module properties.
.PARAMETER PyPyRootDirectory
Root directory where the pypy binaries are located for ManualParse
#>
function Update-PyPyReferences {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName='AutoAdd')]
        [string[]]
        [Alias('python_version')]
        $PythonVersions,

        [Parameter(Mandatory = $true, ParameterSetName = 'ManualParse')]
        [switch]
        $ManualParse,

        [Parameter(Mandatory = $true, ParameterSetName = 'ManualParse')]
        [System.IO.DirectoryInfo]
        $PyPyRootDirectory
    )
    begin {
        . $PSScriptRoot\..\Private\Utility.ps1
        . $PSScriptRoot\..\Private\Set-PyPyLauncherEntry.ps1
        . $PSScriptRoot\..\Private\Set-PyPyPathEntry.ps1
        $PyPyInstallerConfig = Read-PyPyInstallerConfig
        if( -not $ManualParse ) {
            $PyPyInstallations = Get-Content -Path "$( $PyPyInstallerConfig.RootPath )\installs.json" ` | ConvertFrom-Json -AsHashtable
        }
    }
    process {
        if ( -not $ManualParse ) {
            foreach( $PythonVersion in $PythonVersions ) {
                if( -not ( $PyPyInstallations.Contains($PythonVersion) ) ) {
                    throw "Python version $( $PythonVersion ) is not a recognized installation"
                }

                $PyPyInstallation = $PyPyInstallations["$PythonVersion"]
                Set-PyPyLauncherEntry -PyPyVersion $PyPyInstallation.pypy_version -PythonVersion $PyPyInstallation.python_version -InstallPath $PyPyInstallation.install_path
                Set-PyPyPathEntry -InstallPath $PyPyInstallation.install_path
            }
        }
        else {
            $PyPyVersion = Invoke-Expression -Command "$( $PyPyRootDirectory.FullName )\pypy.exe -c 'import sys; pypy_ver = sys.pypy_version_info; print(f`"{pypy_ver.major}.{pypy_ver.minor}.{pypy_ver.micro}`")'"
            $PythonVersion = Invoke-Expression -Command "$( $PyPyRootDirectory.FullName )\pypy.exe -c 'import sys; py_ver = sys.version_info; print(f`"{py_ver.major}.{py_ver.minor}.{py_ver.micro}`")'"
            Set-PyPyLauncherEntry -PyPyVersion $PyPYVersion -PythonVersion $PythonVersion -InstallPath $PyPyRootDirectory
            Set-PyPyPathEntry -InstallPath $PyPyRootDirectory
        }
    }
}