[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$installDirectory = Join-Path $env:LOCALAPPDATA 'SWGU Window Center'
$shortcutPath = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs\SWG Uprising (Centered).lnk'
$uninstallShortcutPath = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs\Uninstall SWGU Window Center.lnk'

if (Test-Path -LiteralPath $shortcutPath) {
    Remove-Item -LiteralPath $shortcutPath -Force
}

if (Test-Path -LiteralPath $uninstallShortcutPath) {
    Remove-Item -LiteralPath $uninstallShortcutPath -Force
}

$expectedPath = [IO.Path]::GetFullPath((Join-Path $env:LOCALAPPDATA 'SWGU Window Center'))
$actualPath = [IO.Path]::GetFullPath($installDirectory)
if ($actualPath -ne $expectedPath) {
    throw 'Refusing to remove an unexpected installation path.'
}

if (Test-Path -LiteralPath $actualPath) {
    Remove-Item -LiteralPath $actualPath -Recurse -Force
}

Write-Host 'Removed SWGU Window Center. The official launcher and game were not changed.'
