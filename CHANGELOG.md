# Changelog

## 1.1.0 — 2026-09-29

- Remove the unreliable automated launcher wrapper and installer.
- Make the tested manual centering workflow the only supported method.
- Find the actual visible window owned by `SWGEmu.exe` instead of relying on PowerShell's sometimes-empty `MainWindowHandle` property.
- Clarify that nothing is installed and removal only requires deleting the extracted folder.
- Retain cleanup instructions for users of older automated releases.

## 1.0.3 — 2026-09-29

- Keep watching through the Uprising Launcher-to-`SWGEmu.exe` handoff.
- Track the game process even before it owns a visible window.
- Allow a grace period when the launcher closes before the game process or window appears.

## 1.0.2 — 2026-09-29

- Retry centering during the first several seconds after the game window appears, accommodating SWGU startup repositioning.
- Require the detected or selected launcher to be named `Uprising Launcher.exe`.
- Clarify that automated centering uses the separate Start-menu shortcut created by the installer.

## 1.0.1 — 2026-09-29

- Find the Uprising Launcher in common per-user and Program Files locations.
- Detect the official Uprising Launcher Start-menu shortcut.
- Show a file picker for custom drives and installation folders.
- Retain the explicit `-LauncherPath` option for advanced use.

## 1.0.0 — 2026-09-29

- Add manual centering for visible `SWGEmu.exe` windows.
- Add optional automated launcher wrapper.
- Add installer that creates a separate Start-menu shortcut without modifying the official launcher.
- Add a Start-menu uninstaller and manual rollback instructions.
- Leave native-size and fullscreen windows untouched.
