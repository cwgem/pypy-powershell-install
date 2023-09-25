# PyPyInstaller

Powershell module to manage PyPy on Windows. This project was created with the goal in mind of providing an easy way to install PyPy versions, as well as make them available in $PATH and through the [Python Launcher(https://docs.python.org/3/using/windows.html#python-launcher-for-windows)]. Functionality of this module exists through individual functions with different options. The mirror list for PyPy versions is downloaded into a cache directory to reduce server hits, and PyPy files will not be downloaded if they already exist in the downloads folder.

Please note that the current codebase has unsigned code. As such the resulting installation method will require security policy bypass to run. The only other way around this would be to purchase a code signing certificate, but those are quite expensive for a project that I'm not sure of the adoption of.

## Thar Be Dragons Here

The current version of this code is mostly a code dump now that a sufficient amount of code coverage is present and the basic installation functionality works.

### Current Status

Right now the status of the codebase is:

- Can locate the latest version of a PyPy package given a Python major.minor version (ex. 3.9)
- Download and extract PyPy zips to a specific installation folder, as well as keeping track of installs
- Add the latest version of a major.minor Python series to PATH and the Python Launcher via [PEP 514](https://peps.python.org/pep-0514/)
- Obtain the latest version of the PyPy mirror list

### What Needs To Be Done

- Vetting the installation method
- Adding more GitHub Actions Workflows to run Pester tests
- List/Remove/Update PyPy versions
- Standardize and fully document the codebase
- Update this README with actual installation and usage instructions
- Work with any contributors / GitHub Issues that may come up