@echo off
setlocal enabledelayedexpansion
title Novaya Ten - Dark Fantasy Platformer
cd /d "%~dp0"

rem 1) Godot exe placed right next to this .bat (easiest option for players)
if exist "%~dp0godot.exe" (
    echo Running project with local godot.exe ...
    "%~dp0godot.exe" --path "%~dp0"
    goto :eof
)

rem 2) godot.exe somewhere on PATH
where godot.exe >nul 2>nul
if %errorlevel%==0 (
    echo Running project with godot.exe from PATH ...
    godot.exe --path "%~dp0"
    goto :eof
)

rem 3) godot (no extension) on PATH
where godot >nul 2>nul
if %errorlevel%==0 (
    echo Running project with godot from PATH ...
    godot --path "%~dp0"
    goto :eof
)

echo.
echo [!] Godot executable not found.
echo.
echo     Either:
echo       1. Download Godot 4.x (Standard, not .NET) from:
echo          https://godotengine.org/download/windows/
echo          and place godot.exe in this same folder, OR
echo       2. Install Godot and add its folder to your PATH.
echo.
pause
exit /b 1
