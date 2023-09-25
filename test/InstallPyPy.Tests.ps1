$PackageRoot = "$PSScriptRoot\..\src\PyPyInstaller\"
Remove-Module PyPyInstaller
Import-Module $PackageRoot -Force
. "$PackageRoot\Functions\Private\Utility.ps1"
. "$PackageRoot\Functions\Private\Get-PyPyDownloadAndExtract.ps1"

InModuleScope PyPyInstaller {
    Describe "Install-PyPy" {
        BeforeAll {
            $TestRootPath = "$env:temp"
            Mock -CommandName Read-PyPyInstallerConfig -MockWith { return @{ RootPath = $TestRootPath } }
            Mock -CommandName Get-Content -ParameterFilter { $Path -eq "$TestRootPath\versions.json" } -MockWith { return Get-Content "$PSScriptRoot\fixtures\test_versions.json" }
            Mock -CommandName Get-PyPyDownloadAndExtract -MockWith { return $null }
            Mock -CommandName Update-PyPyReferences -MockWith { return $null }
        }

        Context "Single Python Version Passed In" {
            $VersionInfo = Get-Content -Path "${PSScriptRoot}\fixtures\test_versions.json" | ConvertFrom-Json | Where-Object -FilterScript {  $PSItem.python_version -eq "3.10.12" }

            It "Returns An Object" {
                Mock -CommandName Get-PyPyDownloadAndExtract -ParameterFilter { $PyPyVersionInfo -eq $VersionInfo } -MockWith { return $null }
                Install-PyPy -PythonVersions "3.10.12" | Where-Object -FilterScript { $PSItem.python_version -eq "3.10.12" } | Should -BeOfType System.Object
            }
            Context "Via Argument" {
                It "Passes Installs Single Version" {
                    Mock -CommandName Get-PyPyDownloadAndExtract -ParameterFilter { $PyPyVersionInfo -eq $VersionInfo } -MockWith { return $null }
                    { Install-PyPy -PythonVersions "3.10.12" } | Should -Not -Throw

                    Assert-MockCalled Get-Content -Exactly -Times 1
                    Assert-MockCalled Get-PyPyDownloadAndExtract -Exactly -Times 1
                    Assert-MockCalled Update-PyPyReferences -Exactly -Times 1
                }
            }
            Context "Via Pipeline" {
                It "Passes Installs Single Version" {
                    Mock -CommandName Get-PyPyDownloadAndExtract -ParameterFilter { $PyPyVersionInfo -eq $VersionInfo } -MockWith { return $null }
                    { ( New-MockObject -Type System.Object -Properties @{ python_version = "3.10.12"  } ) | Install-PyPy } | Should -Not -Throw

                    Assert-MockCalled Get-Content -Exactly -Times 1
                    Assert-MockCalled Get-PyPyDownloadAndExtract -Exactly -Times 1
                    Assert-MockCalled Update-PyPyReferences -Exactly -Times 1
                }
            }
        }

        Context "Registry Option Disabled" {
            It "Installs Without Adding Registry Entries" {
                Install-PyPy -PythonVersions "3.10.12", "3.6.9" -AddRegistryEntries $false

                Assert-MockCalled Get-Content -Exactly -Times 1
                Assert-MockCalled Get-PyPyDownloadAndExtract -Exactly -Times 2
            }
        }

        Context "Multiple Python Versions Passed In" {
            Context "via Argument" {
                It "Installs Multiple Versions Declared Via Argument" {
                    Install-PyPy -PythonVersions "3.10.12", "3.6.9"

                    Assert-MockCalled Get-Content -Exactly -Times 1
                    Assert-MockCalled Get-PyPyDownloadAndExtract -Exactly -Times 2
                    Assert-MockCalled Update-PyPyReferences -Exactly -Times 2
                }
            }

            Context "via Pipeline" {
                It "Installs Multiple Versions Declared Via Pipeline" {
                    ( New-MockObject -Type System.Object -Properties @{ python_version = "3.10.12"  } ),
                    ( New-MockObject -Type System.Object -Properties @{ python_version = "3.6.9"  } )
                    | Install-PyPy

                    Assert-MockCalled Get-Content -Exactly -Times 1
                    Assert-MockCalled Get-PyPyDownloadAndExtract -Exactly -Times 2
                    Assert-MockCalled Update-PyPyReferences -Exactly -Times 2
                }
            }
        }

        Context "Version Comparison Needed" {
            It "Updates Preferences For Latest Version" {
                Mock -CommandName Get-Content -ParameterFilter { $Path -eq "$TestRootPath\versions.json" } -MockWith { return Get-Content "$PSScriptRoot\fixtures\test_comparison_versions.json" }
                Install-PyPy -PythonVersions "3.10.12", "3.10.9"

                Assert-MockCalled Get-Content -Exactly -Times 1
                Assert-MockCalled Get-PyPyDownloadAndExtract -Exactly -Times 2
                Assert-MockCalled Update-PyPyReferences -Exactly -Times 1
            }
        }
    }
}