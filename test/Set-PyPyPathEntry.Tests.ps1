BeforeAll {
    $PackageRoot = "$PSScriptRoot\..\src\PyPyInstaller"
    . "$PackageRoot\Functions\Private\Set-PyPyPathEntry"
    . "$PackageRoot\Wrappers\PathEnvironment.ps1"
}
Describe "Set-PyPyPathEntry" {
    Context "Install Folder Not In Path" {
        It "Adds To The Path" {
            Mock -CommandName Get-PyPyPathEnvironmentVariable -MockWith { return "c:\Test1;C:\Test2" }
            Mock -CommandName Set-PyPyPathEnvironmentVariable -ParameterFilter { $NewPath -eq 'c:\Test1;C:\Test2;C:\PyPy'}
            Set-PyPyPathEntry -InstallPath "C:\PyPy"

            Assert-MockCalled Get-PyPyPathEnvironmentVariable -Exactly -Times 1
            Assert-MockCalled Set-PyPyPathEnvironmentVariable -Exactly -Times 1
        }
    }

    Context "Install Folder In Path" {
        It "Does Not Add To Path" {
            Mock -CommandName Get-PyPyPathEnvironmentVariable -MockWith { return "c:\Test1;C:\PyPy" }
            Mock -CommandName Write-Warning -ParameterFilter { $Message -eq "Folder C:\PyPy already exists in PATH" }
            Set-PyPyPathEntry -InstallPath "C:\PyPy"

            Assert-MockCalled Get-PyPyPathEnvironmentVariable -Exactly -Times 1
            Assert-MockCalled Write-Warning -Exactly -Times 1
        }
    }
}