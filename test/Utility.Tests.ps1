BeforeAll {
    $PackageRoot = "$PSScriptRoot\..\src\PyPyInstaller"
    . "$PackageRoot\Functions\Private\Utility.ps1"
}

Describe "Read-PyPyInstallerConfig" {
    Context "Config File Passed In" {
        It "Passes Loads Configuration" {
            $TestConfig = Read-PyPyInstallerConfig -ConfigFile "$PSScriptRoot\fixtures\test_config.json"
            $TestConfig.RootPath | Should -Be "C:\PyPyInstaller"
        }
    }

    Context "Config File Missing" {
        It "Passes Loads Default Configuration" {
            Mock -CommandName Write-Warning -ParameterFilter { $Message -eq "Config file ${ConfigFile} not found, using defaults" } -MockWith { return $null }
            $TestConfig = Read-PyPyInstallerConfig -ConfigFile "$PSScriptRoot\does_not_exist.json"
            $TestConfig.RootPath | Should -Be "$env:USERPROFILE\.pypy_installer"
        }
    }
}

Describe "Import-PyPyInstallerDefaultConfig" {
    It "Passes Returns Default Configuration" {
        $TestDefaultConfiguration = Import-PyPyInstallerDefaultConfig
        $TestDefaultConfiguration.RootPath | Should -Be "$env:USERPROFILE\.pypy_installer"
    }
}

Describe "Compare-PyPyVersion" {
    Context "Passing Current Is Greater" {
        It "Should Use The Existing Version" {
            Compare-PyPyVersion -CurrentVersion "3.9.2" -PossibleCurrentVersion "3.6.2" | Should -Be $false
        }
    }

    Context "Passing Candidate Version Is Greater" {
        It "Should Use The Newer Version" {
            Compare-PyPyVersion -CurrentVersion "3.5.2" -PossibleCurrentVersion "3.6.2" | Should -Be $true
        }
    }
}