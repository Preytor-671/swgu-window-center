[CmdletBinding()]
param(
    [ValidateRange(0, 600)]
    [int]$WaitSeconds = 120,

    [int]$ProcessId = 0
)

$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.Windows.Forms
if (-not ('SwguWindowApi' -as [type])) {
    Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;

public static class SwguWindowApi
{
    [StructLayout(LayoutKind.Sequential)]
    public struct RECT
    {
        public int Left;
        public int Top;
        public int Right;
        public int Bottom;
    }

    [DllImport("user32.dll")]
    public static extern bool GetWindowRect(IntPtr hWnd, out RECT rect);

    [DllImport("user32.dll")]
    public static extern bool SetWindowPos(
        IntPtr hWnd,
        IntPtr hWndInsertAfter,
        int x,
        int y,
        int cx,
        int cy,
        uint flags);
}
'@
}

function Get-SwguGameWindow {
    $windows = Get-Process -Name 'SWGEmu' -ErrorAction SilentlyContinue |
        Where-Object { $_.MainWindowHandle -ne 0 } |
        Sort-Object StartTime

    if ($ProcessId -gt 0) {
        return $windows | Where-Object Id -eq $ProcessId | Select-Object -First 1
    }

    return $windows | Select-Object -First 1
}

function Center-SwguWindow {
    param([Parameter(Mandatory)]$Process)

    $rect = New-Object SwguWindowApi+RECT
    if (-not [SwguWindowApi]::GetWindowRect($Process.MainWindowHandle, [ref]$rect)) {
        throw 'Windows could not read the SWG window position.'
    }

    $windowWidth = $rect.Right - $rect.Left
    $windowHeight = $rect.Bottom - $rect.Top
    $screen = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds

    # Native-size and fullscreen clients already fill the display. This also
    # makes the utility harmless if SWGU later fixes super-ultrawide support.
    $sizeTolerance = 8
    if (
        $windowWidth -ge ($screen.Width - $sizeTolerance) -and
        $windowHeight -ge ($screen.Height - $sizeTolerance)
    ) {
        return $false
    }

    $x = $screen.Left + [Math]::Floor(($screen.Width - $windowWidth) / 2)
    $y = $screen.Top + [Math]::Floor(($screen.Height - $windowHeight) / 2)
    $SWP_NOSIZE = 0x0001
    $SWP_NOZORDER = 0x0004

    if (-not [SwguWindowApi]::SetWindowPos(
        $Process.MainWindowHandle,
        [IntPtr]::Zero,
        $x,
        $y,
        0,
        0,
        ($SWP_NOSIZE -bor $SWP_NOZORDER)
    )) {
        throw 'Windows could not center the SWG window.'
    }

    return $true
}

$deadline = (Get-Date).AddSeconds($WaitSeconds)
$game = Get-SwguGameWindow

while (-not $game -and (Get-Date) -lt $deadline) {
    Start-Sleep -Milliseconds 500
    $game = Get-SwguGameWindow
}

if (-not $game) {
    throw "SWGEmu.exe was not found within $WaitSeconds seconds. Launch the game and try again."
}

Center-SwguWindow -Process $game | Out-Null
