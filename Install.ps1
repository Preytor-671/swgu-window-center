[CmdletBinding()]
param(
    [string]$LauncherPath
)

$ErrorActionPreference = 'Stop'

function Resolve-UprisingLauncherPath {
    param([string]$RequestedPath)

    function Test-UprisingLauncherPath {
        param([string]$Path)

        return (
            -not [string]::IsNullOrWhiteSpace($Path) -and
            (Test-Path -LiteralPath $Path -PathType Leaf) -and
            ([IO.Path]::GetFileName($Path) -ieq 'Uprising Launcher.exe')
        )
    }

    if (-not [string]::IsNullOrWhiteSpace($RequestedPath)) {
        if (-not (Test-UprisingLauncherPath -Path $RequestedPath)) {
            throw "A valid Uprising Launcher.exe was not found at '$RequestedPath'."
        }
        return [IO.Path]::GetFullPath($RequestedPath)
    }

    $candidates = [Collections.Generic.List[string]]::new()
    $candidates.Add((Join-Path $env:LOCALAPPDATA 'Programs\Uprising Launcher\Uprising Launcher.exe'))
    if (-not [string]::IsNullOrWhiteSpace($env:ProgramFiles)) {
        $candidates.Add((Join-Path $env:ProgramFiles 'Uprising Launcher\Uprising Launcher.exe'))
    }
    if (-not [string]::IsNullOrWhiteSpace(${env:ProgramFiles(x86)})) {
        $candidates.Add((Join-Path ${env:ProgramFiles(x86)} 'Uprising Launcher\Uprising Launcher.exe'))
    }

    $shell = New-Object -ComObject WScript.Shell
    $startMenus = @(
        (Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs'),
        (Join-Path $env:ProgramData 'Microsoft\Windows\Start Menu\Programs')
    ) | Where-Object { -not [string]::IsNullOrWhiteSpace($_) -and (Test-Path -LiteralPath $_ -PathType Container) }

    foreach ($startMenu in $startMenus) {
        foreach ($link in Get-ChildItem -LiteralPath $startMenu -Filter 'Uprising Launcher.lnk' -File -Recurse -ErrorAction SilentlyContinue) {
            $target = $shell.CreateShortcut($link.FullName).TargetPath
            if (-not [string]::IsNullOrWhiteSpace($target)) {
                $candidates.Add($target)
            }
        }
    }

    foreach ($candidate in $candidates) {
        if (Test-UprisingLauncherPath -Path $candidate) {
            return [IO.Path]::GetFullPath($candidate)
        }
    }

    Add-Type -AssemblyName System.Windows.Forms
    $picker = New-Object Windows.Forms.OpenFileDialog
    $picker.Title = 'Select Uprising Launcher.exe'
    $picker.Filter = 'Uprising Launcher (Uprising Launcher.exe)|Uprising Launcher.exe|Applications (*.exe)|*.exe'
    $picker.CheckFileExists = $true
    $picker.Multiselect = $false

    if ($picker.ShowDialog() -ne [Windows.Forms.DialogResult]::OK) {
        throw 'Installation cancelled because Uprising Launcher.exe was not selected.'
    }

    if (-not (Test-UprisingLauncherPath -Path $picker.FileName)) {
        throw 'The selected file must be named Uprising Launcher.exe.'
    }

    return [IO.Path]::GetFullPath($picker.FileName)
}

$LauncherPath = Resolve-UprisingLauncherPath -RequestedPath $LauncherPath

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
