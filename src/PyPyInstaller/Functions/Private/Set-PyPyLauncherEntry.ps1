function Set-PyPyLauncherEntry {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $PyPyVersion,

        [Parameter(Mandatory = $true)]
        [string]
        $PythonVersion,

        [Parameter(Mandatory = $true)]
        [string]
        $InstallPath,

        [Parameter()]
        # TestRegistry is for Pester testing via
        # https://pester.dev/docs/usage/testregistry
        # DO NOT ATTEMPT TO USE THIS REALISTICALLY
        [ValidateSet('HKCU', 'TestRegistry')]
        [string]
        $RegistryDrive = 'HKCU'
    )
    process {
        $ParsedPythonVersion = [version] $PythonVersion
        $RegistryPath = "$( $RegistryDrive ):\Software\Python\PyPyInstaller\$( $ParsedPythonVersion.Major ).$( $ParsedPythonVersion.Minor )"
        $RegistryInstallPath = "$( $RegistryPath )\InstallPath"

        # -Force is actually destructive for registry entries so I'll
        # take the more paranoid approach
        $RegistryKeysToCheck = @(
            "$( $RegistryDrive ):\Software\Python\PyPyInstaller\",
            "$( $RegistryPath )",
            "$( $RegistryInstallPath )"
        )
        foreach ( $RegistryKey in  $RegistryKeysToCheck ) {
            if( ! ( Test-Path -Path $RegistryKey ) ) {
                New-Item -Path $RegistryKey
            }
        }

        New-ItemProperty -Path $RegistryPath  -Name "DisplayName" -Value "PyPy $( $PythonVersion )" -Force
        New-ItemProperty -Path $RegistryPath  -Name "SupportUrl" -Value "https://github.com/cwgem/pypy-powershell-install" -Force
        New-ItemProperty -Path $RegistryPath  -Name "Version" -Value $PyPyVersion -Force
        New-ItemProperty -Path $RegistryPath  -Name "SysVersion" -Value $PythonVersion -Force
        New-ItemProperty -Path $RegistryPath  -Name "SysArchitecture" -Value "64bit" -Force

        Set-Item -Path $RegistryInstallPath -Value $InstallPath
        New-ItemProperty -Path $RegistryInstallPath -Name "ExecutablePath" -Value "$( $InstallPath )\pypy.exe" -Force
        New-ItemProperty -Path $RegistryInstallPath -Name "WindowedExecutablePath" -Value "$( $InstallPath )\pypyw.exe" -Force
    }
}