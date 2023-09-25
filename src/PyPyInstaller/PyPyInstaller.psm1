# Implement your module commands in this script.
Get-ChildItem -Recurse $PSScriptRoot\Functions\*.ps1 | ForEach-Object { . $_.FullName }

# Export only the functions using PowerShell standard verb-noun naming.
# Be sure to list each exported functions in the FunctionsToExport field of the module manifest file.
# This improves performance of command discovery in PowerShell.
Export-ModuleMember -Function Find-PyPyLatest
Export-ModuleMember -Function Update-PyPyMirror
Export-ModuleMember -Function Install-PyPy