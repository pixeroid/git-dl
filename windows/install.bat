@echo off
setlocal EnableDelayedExpansion

set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=!SCRIPT_DIR:~0,-1!"
set "SOURCE=!SCRIPT_DIR!\git-dl.bat"
set "BINARY_NAME=git-dl.bat"
set "TARGET_DIR=%USERPROFILE%\.local\bin"

if not exist "!TARGET_DIR!" (
    mkdir "!TARGET_DIR!"
    echo Created: !TARGET_DIR!
)

rem Add TARGET_DIR to user PATH if not already present
set "IN_PATH="
for %%D in ("%PATH:;=" "%") do (
    if /i "%%~D"=="!TARGET_DIR!" set "IN_PATH=1"
)
if not defined IN_PATH (
    for /f "tokens=2*" %%A in ('reg query "HKCU\Environment" /v Path 2^>nul') do set "USER_PATH=%%B"
    if not defined USER_PATH (
        reg add "HKCU\Environment" /v Path /t REG_EXPAND_SZ /d "!TARGET_DIR!" /f >nul
    ) else (
        reg add "HKCU\Environment" /v Path /t REG_EXPAND_SZ /d "!USER_PATH!;!TARGET_DIR!" /f >nul
    )
    echo Added to PATH: !TARGET_DIR!
    echo NOTE: Open a new terminal for PATH changes to take effect.
)

set "TARGET=!TARGET_DIR!\!BINARY_NAME!"
copy /y "!SOURCE!" "!TARGET!" >nul
echo Installed to: !TARGET!
