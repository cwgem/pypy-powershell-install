Describe 'Module Manifest Tests' {
    It 'Passes Test-ModuleManifest' {
        $ModuleManifestName = 'PyPyInstaller.psd1'
        $ModuleManifestPath = "$PSScriptRoot\..\src\PyPyInstaller\$ModuleManifestName"

        Test-ModuleManifest -Path $ModuleManifestPath | Should -Not -BeNullOrEmpty
        $? | Should -Be $true
    }
}