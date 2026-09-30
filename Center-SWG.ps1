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
using System.Collections.Generic;
using System.Runtime.InteropServices;

public static class SwguWindowApi
{
    public sealed class WindowMatch
    {
        public IntPtr Handle;
        public int ProcessId;
        public int Area;
    }

    private delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);

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
    private static extern bool EnumWindows(EnumWindowsProc callback, IntPtr lParam);

    [DllImport("user32.dll")]
    private static extern bool IsWindowVisible(IntPtr hWnd);

    [DllImport("user32.dll")]
    private static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint processId);

    [DllImport("user32.dll")]
    public static extern bool SetWindowPos(
        IntPtr hWnd,
        IntPtr hWndInsertAfter,
        int x,
        int y,
        int cx,
        int cy,
        uint flags);

    public static WindowMatch[] FindVisibleWindows(int[] processIds)
    {
        var wanted = new HashSet<int>(processIds);
        var matches = new List<WindowMatch>();

        EnumWindows(delegate(IntPtr hWnd, IntPtr lParam)
        {
            uint processId;
            RECT rect;
            GetWindowThreadProcessId(hWnd, out processId);

            if (
                wanted.Contains((int)processId) &&
                IsWindowVisible(hWnd) &&
                GetWindowRect(hWnd, out rect)
            ) {
                int width = rect.Right - rect.Left;
                int height = rect.Bottom - rect.Top;
                if (width > 0 && height > 0) {
                    matches.Add(new WindowMatch {
                        Handle = hWnd,
                        ProcessId = (int)processId,
                        Area = width * height
                    });
                }
            }

            return true;
        }, IntPtr.Zero);

        return matches.ToArray();
    }
}
'@
}

function Get-SwguGameWindow {
    $processes = @(Get-Process -Name 'SWGEmu' -ErrorAction SilentlyContinue)
    if ($ProcessId -gt 0) {
        $processes = @($processes | Where-Object Id -eq $ProcessId)
    }

    if ($processes.Count -eq 0) {
        return $null
    }

    $processIds = [int[]]@($processes | ForEach-Object Id)
    $windows = @([SwguWindowApi]::FindVisibleWindows($processIds) | Sort-Object Area -Descending)
    if ($windows.Count -eq 0) {
        return $null
    }

    return $windows | Select-Object -First 1
}

function Center-SwguWindow {
    param([Parameter(Mandatory)]$Window)

    $rect = New-Object SwguWindowApi+RECT
    if (-not [SwguWindowApi]::GetWindowRect($Window.Handle, [ref]$rect)) {
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
        $Window.Handle,
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

Center-SwguWindow -Window $game | Out-Null
