# SWGU Window Center

An unofficial Windows helper for centering a lower-resolution, borderless Star Wars Galaxies Uprising client on a larger primary monitor.

For example, it centers a `3440x1440` SWG window on a `5120x1440` display, leaving equal space on both sides. It does not resize or scale the game, so the image retains its intended aspect ratio and Alt+Tab remains fast.

> This is a community-made compatibility utility. It is not affiliated with, endorsed by, or distributed by the SWG Uprising team, Lucasfilm, Disney, Daybreak Game Company, or Sony Online Entertainment. Product and game names are used only to describe compatibility.

## Safety and behavior

- Does not modify the game, launcher, configuration, anti-cheat, or installation files.
- Does not access the network or collect telemetry.
- Does not require administrator privileges.
- Centers only windows belonging to `SWGEmu.exe`.
- Leaves native-size and fullscreen windows untouched. If SWGU later fixes `5120x1440`, the helper becomes a no-op at that resolution.
- The automated option creates a separate shortcut and does not replace the official Uprising Launcher shortcut.

The scripts are plain text and can be inspected before use.

## Requirements

- Windows 10 or Windows 11
- SWG Uprising's Windows launcher
- Windows PowerShell 5.1, included with Windows

## Manual option

1. Launch SWG Uprising and enter the game.
2. Run **Center SWG Now.cmd**.
3. The helper waits up to two minutes for `SWGEmu.exe` and centers its window on the primary monitor.

Run the helper again whenever needed. Nothing is installed.

## Automated option

1. Extract the release ZIP to a normal folder.
2. Run **Install.cmd**.
3. Open **SWG Uprising (Centered)** from the Windows Start menu.
4. Use the Uprising launcher normally. Each newly opened SWG window is centered automatically when it is smaller than the primary monitor.

The helper follows the full launcher-to-game handoff. It continues watching while `SWGEmu.exe` starts without a visible window, allows a grace period if the launcher closes first, and checks centering again for several seconds in case SWGU repositions its own window during startup.

The installer copies three readable scripts to `%LOCALAPPDATA%\SWGU Window Center` and creates separate launch and uninstall shortcuts in the Start menu. It does not change the official shortcut.

The installer checks the normal per-user and Program Files locations and any **Uprising Launcher** Start-menu shortcut. If the launcher is installed on another drive or in a custom folder, a file picker asks the user to select `Uprising Launcher.exe`.

Advanced users can also specify the launcher path directly:

```powershell
.\Install.ps1 -LauncherPath 'D:\Path\To\Uprising Launcher.exe'
```

## Removal

Use either removal method:

- Open **Uninstall SWGU Window Center** from the Windows Start menu; or
- Run **Uninstall.cmd** from the extracted release folder.

The uninstaller removes only:

- `%APPDATA%\Microsoft\Windows\Start Menu\Programs\SWG Uprising (Centered).lnk`
- `%APPDATA%\Microsoft\Windows\Start Menu\Programs\Uninstall SWGU Window Center.lnk`
- `%LOCALAPPDATA%\SWGU Window Center`

The official Uprising launcher and game installation are not touched.

### Manual rollback

If the uninstaller cannot be run, delete the two Start-menu shortcuts listed above and then delete `%LOCALAPPDATA%\SWGU Window Center`. You can always launch the game from the original **Uprising Launcher** shortcut, which this utility never changes.

For the manual centering option, nothing is installed. Close the helper and delete the extracted release folder to stop using it.

## Recommended game configuration

For easy Alt+Tab on a super-ultrawide display:

- Windowed mode: enabled
- Borderless window: enabled
- Hardware mouse cursor: enabled
- Use a lower resolution that is stable on your system, such as `3440x1440`

This utility only changes window position. It does not fix rendering crashes or guarantee that a particular resolution will be stable.

## Troubleshooting

- **Nothing moves:** Confirm `SWGEmu.exe` is running and has reached a visible window.
- **The official shortcut does not center the game:** Use the separate **SWG Uprising (Centered)** Start-menu shortcut created by the installer.
- **The game fills the screen:** That is intentional; native-size/fullscreen windows are not moved.
- **The game is centered on the wrong display:** Set the desired display as the Windows primary monitor.
- **Windows warns about an unsigned script:** The `.cmd` launchers use the local Windows PowerShell execution-policy bypass for these files only. Review the source before proceeding.

## License

MIT. See [LICENSE](LICENSE).
