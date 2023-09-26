<#
.SYNOPSIS
Get the latest version of PyPy
.DESCRIPTION
Get the latest overall version of PyPy. Can restrict
by major/minor release as well.
.EXAMPLE
PS> Find-PyPyLatest
.EXAMPLE
PS> Find-PyPyLatest -PythonSeries 3.9
.EXAMPLE
PS> Find-PyPyLatest -PythonSeries 3.9 -Nightly $true
.PARAMETER PythonSeries
Python series to get the latest version for (ex. 3.9)
#>
function Find-PyPyLatest {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        [string[]]
        $PythonSeries
    )

    begin {
        . "$PSScriptRoot\..\Private\Utility.ps1"
        $PyPyInstallerConfig = Read-PyPyInstallerConfig
        $PyPyVersionInfo = Get-Content -Path "$( $PyPyInstallerConfig.RootPath )\versions.json" ` | ConvertFrom-Json

    }

    process {
        if( ! $PythonSeries )
        {
            $LatestPyPyVersion

            foreach ( $PyPyVersion in $PyPyVersionInfo ) {
                if ( -not $PyPyVersion.pypy_version -match "[0-9]+\.[0-9]+\.[0-9]+$" ) {
                    Continue
                }
                if ( -not $LatestPyPyVersion ) {
                    $LatestPyPyVersion = $PyPyVersion
                }
                else {
                    if ( ( Compare-PyPyVersion -PossibleCurrentVersion $PyPyVersion.python_version -CurrentVersion $LatestPyPyVersion.python_version ) ) {
                        $LatestPyPyVersion = $PyPyVersion
                    }
                }
            }

            $VersionReturn = $LatestPyPyVersion
        }
        else {
            $VersionComparison = @{}
            foreach ( $PyPyVersion in $PyPyVersionInfo ) {
                foreach ( $SeriesVersion in $PythonSeries ) {
                    if( $PyPyVersion.python_version -match "$SeriesVersion.[0-9]+$" -and -not $VersionComparison.ContainsKey($SeriesVersion) ) {
                        $VersionComparison[$SeriesVersion] = $PyPyVersion
                    }
                    else {
                        if( $PyPyVersion.python_version -match "$SeriesVersion.[0-9]+$" -and ( Compare-PyPyVersion -PossibleCurrentVersion $PyPyVersion.python_version -CurrentVersion $VersionComparison[$SeriesVersion].python_version ) ) {
                            $VersionComparison[$SeriesVersion] = $PyPyVersion
                        }
                    }
                }
            }
            $VersionReturn = $VersionComparison.Values
        }
    }

    end {
        return $VersionReturn
    }
}