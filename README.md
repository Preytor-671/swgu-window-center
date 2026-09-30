# SWGU Window Center

An unofficial manual Windows helper for centering a lower-resolution, borderless Star Wars Galaxies Uprising client on a larger primary monitor.

For example, it centers a `3440x1440` SWG window on a `5120x1440` display, leaving equal space on both sides. It does not resize or scale the game, so the image retains its intended aspect ratio and Alt+Tab remains fast.

> This is a community-made compatibility utility. It is not affiliated with, endorsed by, or distributed by the SWG Uprising team, Lucasfilm, Disney, Daybreak Game Company, or Sony Online Entertainment. Product and game names are used only to describe compatibility.

## Why manual only?

Earlier releases included an optional automated launcher wrapper. Testing found that the Uprising Launcher-to-game handoff is not consistent enough across systems for that method to be dependable. The automated option was removed in version 1.1.0.

The manual helper is simple and predictable: run it after the game window is visible.

## Safety and behavior

- Does not modify the game, launcher, configuration, anti-cheat, or installation files.
- Does not launch or monitor the Uprising Launcher.
- Does not access the network or collect telemetry.
- Does not require administrator privileges.
- Centers only a visible window belonging to `SWGEmu.exe`.
- Leaves native-size and fullscreen windows untouched. If SWGU later fixes `5120x1440`, the helper becomes a no-op at that resolution.
- Nothing is installed and no shortcuts are replaced.

The scripts are plain text and can be inspected before use.

## Requirements

- Windows 10 or Windows 11
- A running SWG Uprising game window
- Windows PowerShell 5.1, included with Windows

## How to use it

1. Download and extract the latest release ZIP to a normal folder.
2. Launch SWG Uprising normally and wait until the game window is visible.
3. Double-click **Center SWG Now.cmd**.

Run **Center SWG Now.cmd** again whenever the game window needs to be centered.

## Removal

Nothing is installed. Delete the extracted release folder when you no longer want the helper.

If you installed an older automated release, run its **Uninstall.cmd** first or remove:

- `%APPDATA%\Microsoft\Windows\Start Menu\Programs\SWG Uprising (Centered).lnk`
- `%APPDATA%\Microsoft\Windows\Start Menu\Programs\Uninstall SWGU Window Center.lnk`
- `%LOCALAPPDATA%\SWGU Window Center`

The official Uprising launcher and game installation are not affected.

## Recommended game configuration

For easy Alt+Tab on a super-ultrawide display:

- Windowed mode: enabled
- Borderless window: enabled
- Hardware mouse cursor: enabled
- Use a lower resolution that is stable on your system, such as `3440x1440`

This utility only changes window position. It does not fix rendering crashes or guarantee that a particular resolution will be stable.

## Troubleshooting

- **Nothing moves:** Confirm `SWGEmu.exe` is running and has reached a visible game window, then run the helper again.
- **The game fills the screen:** That is intentional; native-size and fullscreen windows are not moved.
- **The game is centered on the wrong display:** Set the desired display as the Windows primary monitor.
- **Windows warns about an unsigned script:** The `.cmd` file uses the local Windows PowerShell execution-policy bypass for this script only. Review the source before proceeding.

## License

MIT. See [LICENSE](LICENSE).
