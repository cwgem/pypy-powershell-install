# PyPyInstaller

Powershell module to manage PyPy on Windows. This project was created with the goal in mind of providing an easy way to install PyPy versions, as well as make them available in $PATH and through the [Python Launcher](https://docs.python.org/3/using/windows.html#python-launcher-for-windows). Functionality of this module exists through individual functions with different options. The mirror list for PyPy versions is downloaded into a cache directory to reduce server hits, and PyPy files will not be downloaded if they already exist in the downloads folder.

## Requirements

The following requirements are needed for this module to work:

- [Powershell 7](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.3)
- A Windows version that supports Powershell 7 ( A listing can be found on the [5.1 migration page](https://learn.microsoft.com/en-us/powershell/scripting/whats-new/migrating-from-windows-powershell-51-to-powershell-7?view=powershell-7.3) )
- A version of [Python for Windows](https://www.python.org/downloads/windows/) that comes bundled with the [Python Launcher](https://docs.python.org/3/using/windows.html#python-launcher-for-windows) if you want [PEP 514](https://peps.python.org/pep-0514/) support to work (the latest version is recommended)

## Installation

Most user setups on windows have a execution policy of RemoteSigned. To make this work out I'd have to fork out around $200 USD for a code signing certificate which is not that realistic for a project I just started. This means `Set-ExecutionPolicy` will have to be used to temporarily bypass this for the installation script. To start out, open up a **Non-Administrative** Powershell session through the Terminal command. All functionality for PyPyInstaller works off the current user so no administrative permissions are required. Now run the following:

```powershell
 > Invoke-WebRequest https://raw.githubusercontent.com/cwgem/pypy-powershell-install/main/Install.ps1 -OutFile Install.ps1
```

Now to run the installer which has several variations:

### Recommended Installation Method

```powershell
> Set-ExecutionPolicy Bypass -Scope Process; .\Install.ps1 -UpdateMirrorList
```

If you're not sure what option to pick this is the recommended.

### Setup Only

```powershell
> Set-ExecutionPolicy Bypass -Scope Process; .\Install.ps1 -SetupOnly
```

This simply sets up the suppporting folders and files and does not download the latest release from GitHub.

### Update Mirrors

```powershell
> Set-ExecutionPolicy Bypass -Scope Process; .\Install.ps1 -UpdateMirrorList
```

This will update the list PyPy versions list from the buildbot mirrors. It's highly recommended to use this for a first install.

### Root Path Directory

```powershell
> Set-ExecutionPolicy Bypass -Scope Process; .\Install.ps1 -RootPath c:\Some\Folder\Somewhere
```

This will update what folder is used for the PyPyInstaller root path. This path is used to store PyPy support files as well as downloads and installations. If you don't designate a directory it will use the `.pypy_installer` in your home directory. Please note that the root path should be a dedicated folder with no other files in it. So don't do this:

**Bad**
```powershell
> Set-ExecutionPolicy Bypass -Scope Process; .\Install.ps1 -RootPath c:\Users\MyUser
```

Instead point it to a dedicated folder like so (the installer script will create underlying parent directories if they don't exist):

**Good**
```powershell
> Set-ExecutionPolicy Bypass -Scope Process; .\Install.ps1 -RootPath c:\Users\MyUser\PyPyInstaller
```

### Post Setup

When you're done with the setup close out the Powershell terminal so the policy bypass is no longer applied. Unless you have one already the installer script will have created a `.pypy_installer_config.json` in your home directory. While defaults are used if the file is missing, please avoid removing it. Currently the only option set is the root path, but other options may come in the future.

## Usage

To start out if you didn't use the recommended `-UpdateMirrorList` option and this is your first time running PyPyInstaller, update the list now:

```powershell
Update-PyPyMirror
```

### Basic Usage

As an example, here is how to install the latest Python 3.9 and 3.10 supported PyPy versions:

```powershell
> Find-PyPyLatest -PythonSeries "3.9", "3.10" | Install-PyPy
```

This will download and extract the files to the appropriate folders under PyPyInstaller's root path, as well as setup PATH and Python Launcher registry entries.

### Separate Execution

You can also run each of the steps manually:

```powershell
> Find-PyPyLatest -PythonSeries "3.8"

pypy_version   : 7.3.11
python_version : 3.8.16
stable         : True
latest_pypy    : True
date           : 2022-12-29
files          : {@{filename=pypy3.8-v7.3.11-aarch64.tar.bz2; arch=aarch64; platform=linux; download_url=https://downlo
                 ads.python.org/pypy/pypy3.8-v7.3.11-aarch64.tar.bz2}, @{filename=pypy3.8-v7.3.11-linux32.tar.bz2; arch
                 =i686; platform=linux; download_url=https://downloads.python.org/pypy/pypy3.8-v7.3.11-linux32.tar.bz2}
                 , @{filename=pypy3.8-v7.3.11-linux64.tar.bz2; arch=x64; platform=linux; download_url=https://downloads
                 .python.org/pypy/pypy3.8-v7.3.11-linux64.tar.bz2}, @{filename=pypy3.8-v7.3.11-macos_x86_64.tar.bz2; ar
                 ch=x64; platform=darwin; download_url=https://downloads.python.org/pypy/pypy3.8-v7.3.11-macos_x86_64.t
                 ar.bz2}…}
> Install-PyPy -PythonVersions "3.8.16"
```

As shown running the `Install-PyPy` command will also allow you to install a specific version which may not be the latest of the series. As indicated by the `-PythonVersions` argument name you can indicate multiple versions through a comma separated list (single versions are dealt with as a single element list):

```powershell
> Install-PyPy -PythonVersions "3.8.16", "3.10.12"
```

### Python Launcher

If you have the Python Launcher installed (see Requirements) Major.Minor versions of PyPy will be available:

```powershell
> py -0p
 -V:3.11 *        C:\Python311\python.exe
 -V:PyPyInstaller/3.10 C:\Users\SomeUser\.pypy_installer\Installs\7.3.12-3.10.12\pypy.exe
 -V:PyPyInstaller/3.9 C:\Users\SomeUser\.pypy_installer\Installs\7.3.12-3.9.17\pypy.exe
 -V:PyPyInstaller/3.8 C:\Users\SomeUser\.pypy_installer\Installs\7.3.11-3.8.16\pypy.exe
```

You can run using the specific PyPy version by running `py` with one of the version tags listed:

```powershell
> py -V:PyPyInstaller/3.10 -c "import sys; print(sys.version_info)"
sys.version_info(major=3, minor=10, micro=12, releaselevel='final', serial=0)
```

## Uninstall

Currently there is no automated uninstall method. The following will remove traces of PyPyInstaller manually:

- Remove PyPyInstaller from the modules directory which is under your Documents folder + `Powershell\Modules\`
- Remove the folder indicated as `RootPath` in `.pypy_installer_config.json` under your home directory
- Remove the `.pypy_installer_config.json`  file under your home directory
- Remove the registry key `Computer\HKEY_CURRENT_USER\Software\Python\PyPyInstaller`
- Remove any PyPy directories from your PATH which can be done via 'edit environment variables for your account` in the Control Panel or through a windows start menu search

## Thar Be Dragons Here

The current version of this code is mostly a code dump now that a sufficient amount of code coverage is present and the basic installation functionality works. Also this is the first real PowerShell project I've worked on so may be less ideal ways to do thing. That said the codebase is 99% coverarge (stil wish I could figure out the remaining %) after fighting with my good friend Pester over weird scoping issues.

### Current Status

Right now the status of the codebase is:

- Can locate the latest version of a PyPy package given a Python major.minor version (ex. 3.9)
- Download and extract PyPy zips to a specific installation folder, as well as keeping track of installs
- Add the latest version of a major.minor Python series to PATH and the Python Launcher via [PEP 514](https://peps.python.org/pep-0514/)
- Obtain the latest version of the PyPy mirror list
- Basic Installation
- README.md updates

### What Needs To Be Done

- Adding more GitHub Actions Workflows to run Pester tests
- List/Remove/Update PyPy versions
- Standardize and fully document the codebase
- Work with any contributors / GitHub Issues that may come up
- Contributor instructions