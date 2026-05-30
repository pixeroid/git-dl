@echo off
setlocal EnableDelayedExpansion

set "BINARY_NAME=git-dl.bat"
set "TARGET=%USERPROFILE%\.local\bin\!BINARY_NAME!"

if not exist "!TARGET!" (
    echo !BINARY_NAME! is not installed.
    exit /b 0
)

del "!TARGET!"
echo Uninstalled: !TARGET!
