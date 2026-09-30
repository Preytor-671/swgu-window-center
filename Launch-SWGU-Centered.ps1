[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$LauncherPath
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $LauncherPath -PathType Leaf)) {
    throw "Uprising Launcher was not found at: $LauncherPath"
}

$centerScript = Join-Path $PSScriptRoot 'Center-SWG.ps1'
if (-not (Test-Path -LiteralPath $centerScript -PathType Leaf)) {
    throw "Centering script was not found at: $centerScript"
}

$launcher = Get-Process -Name 'Uprising Launcher' -ErrorAction SilentlyContinue |
    Where-Object { $_.Path -eq $LauncherPath } |
    Select-Object -First 1

if (-not $launcher) {
    Start-Process -FilePath $LauncherPath | Out-Null
}

$centeredProcessIds = @{}

while ($true) {
    $launchers = Get-Process -Name 'Uprising Launcher' -ErrorAction SilentlyContinue
    $games = @(Get-Process -Name 'SWGEmu' -ErrorAction SilentlyContinue |
        Where-Object { $_.MainWindowHandle -ne 0 })

    foreach ($game in $games) {
        if (-not $centeredProcessIds.ContainsKey($game.Id)) {
            Start-Sleep -Milliseconds 750
            & $centerScript -WaitSeconds 0 -ProcessId $game.Id
            $centeredProcessIds[$game.Id] = $true
        }
    }

    $liveIds = @($games | ForEach-Object Id)
    foreach ($processId in @($centeredProcessIds.Keys)) {
        if ($processId -notin $liveIds) {
            $centeredProcessIds.Remove($processId)
        }
    }

    if (-not $launchers -and $games.Count -eq 0) {
        break
    }

    Start-Sleep -Seconds 1
}
