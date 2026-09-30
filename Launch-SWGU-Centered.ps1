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
$handoffGraceSeconds = 30
$handoffDeadline = (Get-Date).AddSeconds($handoffGraceSeconds)
$launcherWasRunning = $true

while ($true) {
    $launchers = @(Get-Process -Name 'Uprising Launcher' -ErrorAction SilentlyContinue)
    $allGames = @(Get-Process -Name 'SWGEmu' -ErrorAction SilentlyContinue)
    $visibleGames = @($allGames | Where-Object { $_.MainWindowHandle -ne 0 })

    if ($launcherWasRunning -and $launchers.Count -eq 0) {
        $handoffDeadline = (Get-Date).AddSeconds($handoffGraceSeconds)
    }
    $launcherWasRunning = $launchers.Count -gt 0

    foreach ($game in $visibleGames) {
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

    $liveIds = @($allGames | ForEach-Object Id)
    foreach ($processId in @($gameStates.Keys)) {
        if ($processId -notin $liveIds) {
            $gameStates.Remove($processId)
        }
    }

    if (
        $launchers.Count -eq 0 -and
        $allGames.Count -eq 0 -and
        (Get-Date) -ge $handoffDeadline
    ) {
        break
    }

    Start-Sleep -Seconds 1
}
