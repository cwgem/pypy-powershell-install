BeforeAll {
    $script:PackageRoot = "$PSScriptRoot\..\src\PyPyInstaller\"
    $script:TestRootPath = "$env:temp"
    . "$PackageRoot\Functions\Private\Utility.ps1"
}

Describe "Get-PyPyDownloadAndExtract" {
    BeforeAll {
        Mock -CommandName Read-PyPyInstallerConfig -MockWith { return @{ RootPath = $TestRootPath } }
        Mock -CommandName Out-File -ParameterFilter { $FilePath -eq "$TestRootPath\installs.json" } { return $null }
        Mock -CommandName Get-Content -ParameterFilter { $Path -eq "$TestRootPath\installs.json" } -MockWith { return Get-Content -Path "$PSScriptRoot\fixtures\test_installs.json" }

        function Assert-GetPyPyDownloadAndExtract {
            param (
                [Parameter(Mandatory = $true)][string]$PythonVersion,
                [Parameter()][switch]$InstallJsonExists,
                [Parameter()][switch]$InstallFolderExists,
                [Parameter()][switch]$DownloadExists
            )
            begin {
                . "$PackageRoot\Functions\Private\Get-PyPyDownloadAndExtract.ps1"
            }
            process {
                $VersionInfo = Get-Content "$PSScriptRoot\fixtures\test_versions.json" | ConvertFrom-Json | Where-Object -FilterScript {  $PSItem.python_version -eq $PythonVersion }
                $PythonVersionInfo = [version]$PythonVersion

                $PyPyVersion = $VersionInfo.pypy_version
                $PyPyZip = "pypy$( $PythonVersionInfo.Major ).$( $PythonVersionInfo.Minor )-v$PyPyVersion-win64.zip"
                $PyPyInstallPath = "$TestRootPath\Installs\$PyPyVersion-$PythonVersion"
                $PyPyDownloadUrl = "https://downloads.python.org/pypy/$PyPyZip"
                $PyPyZipDest = "$TestRootPath\Downloads\$PyPyZip"

                Mock -CommandName New-Item -ParameterFilter { $ItemType -eq "Directory" -and $Path-eq $PyPyInstallPath -and $Force -eq $true } -MockWith { return New-Object -TypeName System.Object -Property @{}  }
                Mock -CommandName New-Item -ParameterFilter { $ItemType -eq "Directory" -and $Path-eq "$TestRootPath\Downloads" -and $Force -eq $true } -MockWith { return New-Object -TypeName System.Object -Property @{}  }

                Mock -CommandName Test-Path -ParameterFilter { $Path -eq "$TestRootPath\installs.json" } -MockWith { return $InstallJsonExists }
                Mock -CommandName Test-Path -ParameterFilter { $Path -eq $PyPyInstallPath } -MockWith { return $InstallFolderExists }
                Mock -CommandName Test-Path -ParameterFilter { $Path -eq $PyPyZipDest } -MockWith { return $DownloadExists }

                Mock -CommandName Invoke-WebRequest -ParameterFilter { $Uri -eq $PyPyDownloadUrl -and $OutFile -eq $PyPyZipDest } -MockWith { return $null }
                Mock -CommandName Expand-Archive -ParameterFilter { $Path -eq $PyPyZipDest -and $DestinationPath -eq $PyPyInstallPath -and $Force -eq $true } -MockWith { return $null }

                Mock -CommandName Get-ChildItem -ParameterFilter { $Path -eq $PyPyInstallPath } -MockWith { return New-MockObject -Type System.Object -Properties @{ 'FullName' = "$( $env:temp )\PyPyTest"} }
                Mock -CommandName Move-Item -MockWith { return $null }
                Mock -CommandName Remove-Item -MockWith { return $null }

                Mock -CommandName Write-Warning -ParameterFilter { $Message -eq 'Target directory already found, skipping'} -MockWith { return $null }
            }
            end {
                return Get-PyPyDownloadAndExtract -PyPyVersionInfo $VersionInfo
            }
        }
    }

    Context "With Python Version Provided" {
        It "Returns Nothing" {
            Assert-GetPyPyDownloadAndExtract -PythonVersion '3.10.12' -InstallJsonExists | Where-Object -FilterScript { $PSItem.python_version -eq "3.10.12" } | Should -BeNullOrEmpty
        }
        It "Downloads And Extracts The Correct Version" {
            { Assert-GetPyPyDownloadAndExtract -PythonVersion '3.10.12' -InstallJsonExists } | Should -Not -Throw

            Assert-MockCalled New-Item -Exactly -Times 2
            Assert-MockCalled Invoke-WebRequest -Exactly -Times 1
            Assert-MockCalled Expand-Archive -Exactly -Times 1
            Assert-MockCalled Test-Path -Exactly -Times 3
            Assert-MockCalled Get-Content -Exactly -Times 1
            Assert-MockCalled Get-ChildItem -Exactly -Times 1
            Assert-MockCalled Move-Item -Exactly -Times 1
            Assert-MockCalled Remove-Item -Exactly -Times 1
        }
    }

    Context "With Download File Present" {
        It "Does Not Download The File" {
            { Assert-GetPyPyDownloadAndExtract -PythonVersion '3.10.12' -DownloadExists -InstallJsonExists } | Should -Not -Throw

            Assert-MockCalled New-Item -Exactly -Times 2
            Assert-MockCalled Test-Path -Exactly -Times 3
            Assert-MockCalled Expand-Archive -Exactly -Times 1
            Assert-MockCalled Get-Content -Exactly -Times 1
            Assert-MockCalled Get-ChildItem -Exactly -Times 1
            Assert-MockCalled Move-Item -Exactly -Times 1
            Assert-MockCalled Remove-Item -Exactly -Times 1
        }
    }

    Context "Install Folder Present" {
        It "Doesn't Install" {
            { Assert-GetPyPyDownloadAndExtract -PythonVersion '3.10.12' -InstallFolderExists } | Should -Not -Throw

            Assert-MockCalled New-Item -Exactly -Times 1
            Assert-MockCalled Test-Path -Exactly -Times 1
            Assert-MockCalled Write-Warning -Exactly -Times 1
        }
    }


    Context "Without Install File Present" {
        It "Downloads And Extracts The Correct Version" {
            { Assert-GetPyPyDownloadAndExtract -PythonVersion '3.10.12' } | Should -Not -Throw

            Assert-MockCalled New-Item -Exactly -Times 2
            Assert-MockCalled Invoke-WebRequest -Exactly -Times 1
            Assert-MockCalled Expand-Archive -Exactly -Times 1
            Assert-MockCalled Test-Path -Exactly -Times 3
            Assert-MockCalled Get-ChildItem -Exactly -Times 1
            Assert-MockCalled Move-Item -Exactly -Times 1
            Assert-MockCalled Remove-Item -Exactly -Times 1
        }
    }

    Context "Requested Version Has No Windows Download Available" {
        It "Throws An Exception" {
            { Assert-GetPyPyDownloadAndExtract -PythonVersion '3.6.9' } | Should -Throw -ExpectedMessage "No win64 version of requested installation found"
        }
    }
}