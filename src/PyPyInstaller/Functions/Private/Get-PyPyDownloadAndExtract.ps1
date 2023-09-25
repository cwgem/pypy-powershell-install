function Get-PyPyDownloadAndExtract {
    param (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $PyPyVersionInfo
    )
    begin {
        . $PSScriptRoot\Utility.ps1
        $PyPyInstallerConfig = Read-PyPyInstallerConfig
    }
    process {
        [string]$DownloadFileUrl
        foreach ( $PyPyDownload in $PyPyVersionInfo.files ) {
            if ( $PyPyDownload.platform -eq "win64" ){
                $DownloadFileUrl = $PyPyDownload.download_url
                break
            }
        }

        if ( -not $DownloadFileUrl ) {
            throw "No win64 version of requested installation found"
        }

        $PyPyDownloadDirectory = "$( $PyPyInstallerConfig.RootPath )\Downloads"
        $PyPyInstallDirectory = "$( $PyPyInstallerConfig.RootPath )\Installs\$( $PyPyVersionInfo.pypy_version )-$( $PyPyVersionInfo.python_version )"

        New-Item -ItemType Directory -Path $PyPyDownloadDirectory -Force

        if( -not ( Test-Path -Path $PyPyInstallDirectory ) ){
            New-Item -ItemType Directory -Path $PyPyInstallDirectory -Force
            $DownloadFileName = $DownloadFileUrl.Split("/")[-1]
            if( -not (Test-Path -Path "$( $PyPyDownloadDirectory )\$( $DownloadFileName )")){
                Invoke-WebRequest -Uri $DownloadFileUrl -OutFile "$( $PyPyDownloadDirectory )\$( $DownloadFileName )"
            }

            Expand-Archive -Path "$( $PyPyDownloadDirectory )\$( $DownloadFileName )" -DestinationPath $PyPyInstallDirectory -Force
            # The archive has a toplevel folder, so need to move everything from that to our install directory
            $SubFolder = Get-ChildItem -Path $PyPyInstallDirectory | Select-Object -First 1
            Move-Item -Path "$( $SubFolder.FullName )\*" -Destination $PyPyInstallDirectory
            Remove-Item $SubFolder.FullName

            $PyPyInstallFile =  "$( $PyPyInstallerConfig.RootPath )\installs.json"
            if ( ( Test-Path -Path $PyPyInstallFile ) ) {
                $PyPyInstallInfo = Get-Content -Path $PyPyInstallFile | ConvertFrom-Json -AsHashtable
                $PyPyInstallInfo["$($PyPyVersionInfo.python_version)"] = [ordered] @{
                    python_version = $VersionInfo.python_version
                    pypy_version = $VersionInfo.pypy_version
                    install_path = $PyPyInstallDirectory
                }
                $PyPyInstallInfo | ConvertTo-Json | Out-File $PyPyInstallFile
            }
            else {
                @{ $VersionInfo.python_version = @{
                    'pypy_version' =  $VersionInfo.pypy_version;
                    'python_version' = $VersionInfo.python_version
                    'install_path' = $PyPyInstallDirectory
                } } | ConvertTo-Json | Out-File $PyPyInstallFile
            }
        }
        else {
            Write-Warning -Message "Target directory already found, skipping"
        }
    }
}