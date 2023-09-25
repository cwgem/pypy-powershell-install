BeforeAll {
    $PackageRoot = "$PSScriptRoot\..\src\PyPyInstaller\"
    Import-Module $PackageRoot
    . "$PackageRoot\Functions\Private\Utility.ps1"
}
InModuleScope PyPyInstaller {
    Describe "Update-PyPyMirror" {
        BeforeAll {
            $TestRootPath = "$env:temp"
            Mock -CommandName Read-PyPyInstallerConfig -MockWith { return @{ RootPath = $TestRootPath } }
            Mock -CommandName Out-File -ParameterFilter { $FilePath -eq "$TestRootPath\versions.json" } -MockWith { return $null }
            Mock -CommandName Invoke-WebRequest -ParameterFilter { $Uri -eq "https://buildbot.pypy.org/mirror/versions.json" } -MockWith { return @{ Content = Get-Content "$PSScriptRoot\fixtures\test_versions.json" } }
        }
        It "Passes Downloads Mirror JSON" {
            Update-PyPyMirror
            Assert-MockCalled Invoke-WebRequest -Exactly -Times 1 -ParameterFilter { $Uri -eq "https://buildbot.pypy.org/mirror/versions.json" } -Scope It
            Assert-MockCalled Out-File -ParameterFilter { $FilePath -eq "$TestRootPath\versions.json" }
        }
    }
}