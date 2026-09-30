[CmdletBinding()]
param(
    [string]$LauncherPath = (Join-Path $env:LOCALAPPDATA 'Programs\Uprising Launcher\Uprising Launcher.exe')
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $LauncherPath -PathType Leaf)) {
    throw "Uprising Launcher was not found at '$LauncherPath'. Run Install.ps1 with -LauncherPath pointing to Uprising Launcher.exe."
}

$installDirectory = Join-Path $env:LOCALAPPDATA 'SWGU Window Center'
$shortcutPath = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs\SWG Uprising (Centered).lnk'
$uninstallShortcutPath = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs\Uninstall SWGU Window Center.lnk'
$shortcutDirectory = Split-Path -Parent $shortcutPath
$requiredFiles = @('Center-SWG.ps1', 'Launch-SWGU-Centered.ps1', 'Uninstall.ps1')

New-Item -ItemType Directory -Path $installDirectory -Force | Out-Null
New-Item -ItemType Directory -Path $shortcutDirectory -Force | Out-Null

foreach ($file in $requiredFiles) {
    $source = Join-Path $PSScriptRoot $file
    if (-not (Test-Path -LiteralPath $source -PathType Leaf)) {
        throw "Required release file is missing: $file"
    }
    Copy-Item -LiteralPath $source -Destination (Join-Path $installDirectory $file) -Force
}

$powerShellPath = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
$installedLauncherScript = Join-Path $installDirectory 'Launch-SWGU-Centered.ps1'
$escapedScript = $installedLauncherScript.Replace('"', '""')
$escapedLauncher = $LauncherPath.Replace('"', '""')

$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = $powerShellPath
$shortcut.Arguments = "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$escapedScript`" -LauncherPath `"$escapedLauncher`""
$shortcut.WorkingDirectory = $installDirectory
$shortcut.IconLocation = "$LauncherPath,0"
$shortcut.Description = 'Launch SWG Uprising and center smaller borderless game windows'
$shortcut.Save()

$installedUninstallScript = Join-Path $installDirectory 'Uninstall.ps1'
$escapedUninstallScript = $installedUninstallScript.Replace('"', '""')
$uninstallShortcut = $shell.CreateShortcut($uninstallShortcutPath)
$uninstallShortcut.TargetPath = $powerShellPath
$uninstallShortcut.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$escapedUninstallScript`""
$uninstallShortcut.WorkingDirectory = $installDirectory
$uninstallShortcut.Description = 'Remove SWGU Window Center without changing SWG Uprising'
$uninstallShortcut.Save()

Write-Host 'Installed SWGU Window Center.'
Write-Host "Start-menu shortcut: $shortcutPath"
Write-Host "Uninstall shortcut: $uninstallShortcutPath"
Write-Host 'The official Uprising Launcher shortcut was not changed.'
