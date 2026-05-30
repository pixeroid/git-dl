@echo off
setlocal EnableDelayedExpansion

set "BINARY_NAME=git-dl.bat"
set "TARGET="

for /f "delims=" %%P in ('where "!BINARY_NAME!" 2^>nul') do (
    if not defined TARGET set "TARGET=%%P"
)

if not defined TARGET (
    echo !BINARY_NAME! is not installed.
    exit /b 0
)

del "!TARGET!"
echo Uninstalled: !TARGET!
