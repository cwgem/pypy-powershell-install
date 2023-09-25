BeforeAll {
    $PackageRoot = "$PSScriptRoot\..\src\PyPyInstaller"
    . "$PackageRoot\Functions\Private\Set-PyPyLauncherEntry.ps1"
}

Describe "Set-PyPyLauncherEntry" {
    Context "Registry Keys Don't Exist" {
        BeforeAll {
            New-Item -Path "TestRegistry:\Software\Python" -Force
            Mock -CommandName Test-Path -MockWith { return $false }
        }
        It "Passes Adds Entries To Registry" {
            Set-PyPyLauncherEntry -PythonVersion "3.10.12" -PyPyVersion "7.3.12" -InstallPath "C:\PyPy" -RegistryDrive "TestRegistry"

            $CoreInfo = Get-ItemProperty "TestRegistry:\Software\Python\PyPyInstaller\3.10"
            $CoreInfo.DisplayName | Should -Be "PyPy 3.10.12"
            $CoreInfo.SupportUrl | Should -Be "https://github.com/cwgem/pypy-powershell-install"
            $CoreInfo.Version | Should -Be "7.3.12"
            $CoreInfo.SysVersion | Should -Be "3.10.12"
            $CoreInfo.SysArchitecture | Should -Be "64bit"

            $InstallPathInfo = Get-ItemProperty "TestRegistry:\Software\Python\PyPyInstaller\3.10\InstallPath"
            $InstallPathInfo.'(default)' | Should -Be "C:\PyPy"
            $InstallPathInfo.ExecutablePath | Should -Be "C:\PyPy\pypy.exe"
            $InstallPathInfo.WindowedExecutablePath | Should -Be "C:\PyPy\pypyw.exe"
        }
    }

    Context "Registry Keys Exist" {
        BeforeAll {
            New-Item -Path "TestRegistry:\Software\Python\PyPyInstaller\3.10\InstallPath" -Force
            $RegistryPath = "TestRegistry:\Software\Python\PyPyInstaller\3.10"
            New-ItemProperty -Path $RegistryPath  -Name "DisplayName" -Value "PyPy 7.3.11"
            New-ItemProperty -Path $RegistryPath  -Name "SupportUrl" -Value "https://github.com/cwgem/pypy-powershell-install"
            New-ItemProperty -Path $RegistryPath  -Name "Version" -Value "3.9.6"
            New-ItemProperty -Path $RegistryPath  -Name "SysVersion" -Value "3.9.6"
            New-ItemProperty -Path $RegistryPath  -Name "SysArchitecture" -Value "64bit"
            Mock -CommandName Test-Path -MockWith { return $true }
        }
        It "Passes Adds Entries To Registry" {
            Set-PyPyLauncherEntry -PythonVersion "3.10.12" -PyPyVersion "7.3.12" -InstallPath "C:\PyPy" -RegistryDrive "TestRegistry"

            $CoreInfo = Get-ItemProperty "TestRegistry:\Software\Python\PyPyInstaller\3.10"
            $CoreInfo.DisplayName | Should -Be "PyPy 3.10.12"
            $CoreInfo.SupportUrl | Should -Be "https://github.com/cwgem/pypy-powershell-install"
            $CoreInfo.Version | Should -Be "7.3.12"
            $CoreInfo.SysVersion | Should -Be "3.10.12"
            $CoreInfo.SysArchitecture | Should -Be "64bit"

            $InstallPathInfo = Get-ItemProperty "TestRegistry:\Software\Python\PyPyInstaller\3.10\InstallPath"
            $InstallPathInfo.'(default)' | Should -Be "C:\PyPy"
            $InstallPathInfo.ExecutablePath | Should -Be "C:\PyPy\pypy.exe"
            $InstallPathInfo.WindowedExecutablePath | Should -Be "C:\PyPy\pypyw.exe"
        }
    }
}