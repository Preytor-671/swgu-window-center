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

$gameStates = @{}
$retryIntervalSeconds = 2
$maximumAttempts = 8

while ($true) {
    $launchers = Get-Process -Name 'Uprising Launcher' -ErrorAction SilentlyContinue
    $games = @(Get-Process -Name 'SWGEmu' -ErrorAction SilentlyContinue |
        Where-Object { $_.MainWindowHandle -ne 0 })

    foreach ($game in $games) {
        if (-not $gameStates.ContainsKey($game.Id)) {
            $gameStates[$game.Id] = [pscustomobject]@{
                Attempts = 0
                NextAttempt = Get-Date
            }
        }

        $state = $gameStates[$game.Id]
        if ($state.Attempts -lt $maximumAttempts -and (Get-Date) -ge $state.NextAttempt) {
            & $centerScript -WaitSeconds 0 -ProcessId $game.Id
            $state.Attempts++
            $state.NextAttempt = (Get-Date).AddSeconds($retryIntervalSeconds)
        }
    }

    $liveIds = @($games | ForEach-Object Id)
    foreach ($processId in @($gameStates.Keys)) {
        if ($processId -notin $liveIds) {
            $gameStates.Remove($processId)
        }
    }

    if (-not $launchers -and $games.Count -eq 0) {
        break
    }

    Start-Sleep -Seconds 1
}
