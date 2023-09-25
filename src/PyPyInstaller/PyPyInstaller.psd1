@{

# Script module or binary module file associated with this manifest.
RootModule = 'PyPyInstaller.psm1'

# Version number of this module.
ModuleVersion = '0.0.1'

# Supported PSEditions
CompatiblePSEditions = @('Core', 'Desktop')

# ID used to uniquely identify this module
GUID = 'ffa1ecb8-56e4-47b9-bdf6-8475e943a7de'

# Author of this module
Author = 'Chris White'

# Company or vendor of this module
CompanyName = 'cwprogram.com'

# Copyright statement for this module
Copyright = '(c) Chris White. All rights reserved.'

# Description of the functionality provided by this module
Description = 'Manage PyPy installations on Windows'

# Minimum version of the PowerShell engine required by this module
PowerShellVersion = '7.0'

# Processor architecture (None, X86, Amd64) required by this module
ProcessorArchitecture = 'AMD64'

# Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
FunctionsToExport = @('Find-PyPyLatest', 'Update-PyPyMirror', 'Install-PyPy')

# Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
CmdletsToExport = '*'

# Variables to export from this module
VariablesToExport = '*'

# Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
AliasesToExport = '*'

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = @('PackageManagement', "Windows", "Python", "PyPY")

        # A URL to the license for this module.
        LicenseUri = 'https://github.com/cwgem/pypy-powershell-install/blob/main/LICENSE'

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/cwgem/pypy-powershell-install'

        # ReleaseNotes of this module
        ReleaseNotes = @'
## 0.0.1 Release Notes

### New Features
- Initial Installer
- CI/CD to create ZIP file for code
- Initial Module Release
'@

        # Flag to indicate whether the module requires explicit user acceptance for install/update/save
        RequireLicenseAcceptance = $false

    } # End of PSData hashtable

}

# HelpInfo URI of this module
HelpInfoURI = 'https://github.com/cwgem/pypy-powershell-install/blob/main/README.md'

}


