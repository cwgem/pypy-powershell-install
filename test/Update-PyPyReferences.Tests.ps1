
$PackageRoot = "$PSScriptRoot\..\src\PyPyInstaller\"
Remove-Module PyPyInstaller
Import-Module $PackageRoot -Force
. "$PackageRoot\Functions\Private\Utility.ps1"
. "$PackageRoot\Functions\Private\Set-PyPyLauncherEntry.ps1"

InModuleScope PyPyInstaller {
    Describe "Update-PyPyReferences" {
        BeforeAll {
            $TestRootPath = "$env:temp"
            Mock -CommandName Read-PyPyInstallerConfig -MockWith { return @{ RootPath = $TestRootPath } }
            Mock -CommandName Get-Content -ParameterFilter { $Path -eq "$TestRootPath\installs.json" } -MockWith { return Get-Content "$PSScriptRoot\fixtures\test_installs.json" }
            Mock -CommandName Set-PyPyLauncherEntry -ParameterFilter { $PyPyVersion -eq "7.3.3" -and  $PythonVersion -eq  "3.7.9" -and  $InstallPath -eq "C:\Installs\7.3.3-3.7.9" } -MockWith { return $null }
            Mock -CommandName Set-PyPyLauncherEntry -ParameterFilter { $PyPyVersion -eq "7.3.11" -and  $PythonVersion -eq  "3.9.16" -and  $InstallPath -eq "C:\Installs\7.3.11-3.9.16" } -MockWith { return $null }
            Mock -CommandName Set-PyPyPathEntry -ParameterFilter { $InstallPath -eq "C:\Installs\7.3.3-3.7.9" } -MockWith { return $null }
            Mock -CommandName Set-PyPyPathEntry -ParameterFilter { $InstallPath -eq "C:\Installs\7.3.11-3.9.16" } -MockWith { return $null }
        }

        Context "Auto Detect" {
            It "Passes Adds 3.7.9 Registry Entry" {
                Update-PyPyReferences -PythonVersions "3.7.9"
                Assert-MockCalled Set-PyPyLauncherEntry -Exactly -Times 1 -Scope It
                Assert-MockCalled Set-PyPyPathEntry -Exactly -Times 1 -Scope It
                Assert-MockCalled Get-Content -Exactly -Times 1 -Scope It
            }

            It "Passes Adds 3.7.9 and 3.9.16 Registry Entry" {
                Update-PyPyReferences -PythonVersions "3.7.9", "3.9.16"
                Assert-MockCalled Set-PyPyLauncherEntry -Exactly -Times 2 -Scope It
                Assert-MockCalled Set-PyPyPathEntry -Exactly -Times 2 -Scope It
                Assert-MockCalled Get-Content -Exactly -Times 1 -Scope It
            }
        }

        Context "Requested Installation Not Present In Install JSON"{
            It "Passes Throws Execption" {
                { Update-PyPyReferences -PythonVersions "3.6.1" } | Should -Throw -ExpectedMessage "Python version 3.6.1 is not a recognized installation"
            }
        }

        Context "ManualParse" {
            BeforeAll {
                Mock -CommandName Invoke-Expression -ParameterFilter { $Command -eq "C:\PyPy\pypy.exe -c 'import sys; pypy_ver = sys.pypy_version_info; print(f`"{pypy_ver.major}.{pypy_ver.minor}.{pypy_ver.micro}`")'" } -MockWith { return "7.3.12" }
                Mock -CommandName Invoke-Expression -ParameterFilter { $Command -eq "C:\PyPy\pypy.exe -c 'import sys; py_ver = sys.version_info; print(f`"{py_ver.major}.{py_ver.minor}.{py_ver.micro}`")'" } -MockWith { return "3.10.12" }
                Mock -CommandName Set-PyPyLauncherEntry -ParameterFilter { $PyPyVersion -eq "7.3.12" -and  $PythonVersion -eq  "3.10.12" -and  $InstallPath -eq "C:\PyPy" } -MockWith { return $null }
                Mock -CommandName Set-PyPyPathEntry -ParameterFilter { $InstallPath -eq "C:\PyPy" } -MockWith { return $null }
            }
            It "Passes Manual Parsing Succeeds" {
                Update-PyPyReferences -ManualParse -PyPyRootDirectory C:\PyPy
                Assert-MockCalled Set-PyPyLauncherEntry -Exactly -Times 1 -Scope It
                Assert-MockCalled Set-PyPyPathEntry -Exactly -Times 1 -Scope It
                Assert-MockCalled Invoke-Expression -Exactly -Times 2
                Assert-MockCalled Get-Content -Exactly -Times 0 -Scope It
            }
        }

        Context "Python Versions Passed Via Pipeline" {
            BeforeAll {
                Mock -CommandName Get-Content -ParameterFilter { $Path -eq "$TestRootPath\installs.json" } -MockWith { return Get-Content "$PSScriptRoot\fixtures\test_installs.json" }
            }
            It "Passes Pipeline With Single Value" {
                New-MockObject -Type System.Object -Properties @{ python_version = "3.7.9" } | Update-PyPyReferences
                Assert-MockCalled Set-PyPyLauncherEntry -Exactly -Times 1 -Scope It
                Assert-MockCalled Set-PyPyPathEntry -Exactly -Times 1 -Scope It
                Assert-MockCalled Get-Content -Exactly -Times 1 -Scope It
            }

            It "Passes Pipeline With Multiple Value" {
                ( New-MockObject -Type System.Object -Properties @{'python_version' = "3.9.16"} ), ( New-MockObject -Type System.Object -Properties @{'python_version' = "3.7.9"} ) | Update-PyPyReferences
                Assert-MockCalled Set-PyPyLauncherEntry -Exactly -Times 2 -Scope It
                Assert-MockCalled Set-PyPyPathEntry -Exactly -Times 2 -Scope It
                Assert-MockCalled Get-Content -Exactly -Times 1 -Scope It
            }
        }
    }
}