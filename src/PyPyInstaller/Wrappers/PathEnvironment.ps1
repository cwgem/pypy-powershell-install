# These are wrappers around .NET class calls for environment variable
# manipulation. These were chosen over traditional $env manipulation as
# it will trigger the WM_SETTINGCHANGE event so environment variables
# are refreshed without logout
#
# https://serverfault.com/a/876297
function Get-PyPyPathEnvironmentVariable {
    return [System.Environment]::GetEnvironmentVariable('Path', 'User')
}

function Set-PyPyPathEnvironmentVariable {
    param (
        [Parameter()]
        [String]
        $NewPath
    )
    [System.Environment]::SetEnvironmentVariable('Path', $NewPath, 'User')
}