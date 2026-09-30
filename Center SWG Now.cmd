@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Center-SWG.ps1"
if errorlevel 1 pause
