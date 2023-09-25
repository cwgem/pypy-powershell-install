$PackageRoot = "$PSScriptRoot\..\src\PyPyInstaller\"
Import-Module $PackageRoot -Force
. "$PackageRoot\Functions\Private\Utility.ps1"

InModuleScope PyPyInstaller {
    Describe "Find-PyPyLatest" {
        BeforeAll {
            $TestRootPath = "$env:temp"
            Mock -CommandName Read-PyPyInstallerConfig -MockWith { return @{ RootPath = $TestRootPath } }
            Mock -CommandName Get-Content -ParameterFilter { $Path -eq "$TestRootPath\versions.json" } -MockWith { return Get-Content "$PSScriptRoot\fixtures\test_versions.json" }
        }

        Context "No version or nightly defined" {
            It "Passes Returns 3.10.12 Version" {
                $PyPyVersionInfo = Find-PyPyLatest
                Assert-MockCalled Get-Content -Exactly -Times 1 -Scope It
                $PyPyVersionInfo.python_version | Should -Be "3.10.12"
            }

            It "Passes Returns A Hashtable" {
                Find-PyPyLatest | Should -BeOfType System.Object
            }
        }

        Context "Python Series Defined" {
            It "Passes Returns A Hash Table" {
                Find-PyPyLatest -PythonSeries "3.6" | Should -BeOfType System.Object
            }

            It "Passes Single Series Download" {
                $PyPyVersions = Find-PyPyLatest -PythonSeries "3.6"
                $PyPyVersions.python_version | Should -Be "3.6.9"
                Assert-MockCalled Get-Content -Exactly -Times 1
            }

            It "Passes Multi-Series Download" {
                $PyPyVersions = Find-PyPyLatest -PythonSeries "3.6", "3.7"
                Assert-MockCalled Get-Content -Exactly -Times 1 -Scope It
                $PyPyVersions.Count | Should -Be 2
                $PyPyVersions |  Select-Object -ExpandProperty python_version | Should -BeIn @( '3.6.9', '3.7.9')
            }
        }

        Context "Python Series Passed Via Pipeline" {
            It "Passes Single Series Download" {
                $PyPyVersions = Write-Output "3.6" | Find-PyPyLatest
                Assert-MockCalled Get-Content -Exactly -Times 1
                $PyPyVersions.python_version | Should -Be "3.6.9"
            }

            It "Passes Multi-Series Download" {
                $PyPyVersions = Write-Output "3.6", "3.7" -NoEnumerate | Find-PyPyLatest
                Assert-MockCalled Get-Content -Exactly -Times 1 -Scope It
                $PyPyVersions.Keys.Count | Should -Be 2
                $PyPyVersions |  Select-Object -ExpandProperty python_version | Should -BeIn @( '3.6.9', '3.7.9')
            }
        }
    }
}