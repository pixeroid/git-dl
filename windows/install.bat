@echo off
setlocal EnableDelayedExpansion

set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=!SCRIPT_DIR:~0,-1!"
set "SOURCE=!SCRIPT_DIR!\git-dl.bat"
set "BINARY_NAME=git-dl.bat"
set "TARGET_DIR="

rem Find first user-writable directory on PATH
for %%D in ("%PATH:;=" "%") do (
    if not defined TARGET_DIR (
        set "CANDIDATE=%%~D"
        if exist "!CANDIDATE!" (
            rem Test write access by attempting to create and delete a temp file
            set "PROBE=!CANDIDATE!\git-dl-probe-%RANDOM%.tmp"
            copy /y nul "!PROBE!" >nul 2>&1
            if exist "!PROBE!" (
                del "!PROBE!" >nul 2>&1
                set "TARGET_DIR=!CANDIDATE!"
            )
        )
    )
)

if not defined TARGET_DIR (
    echo Error: No user-writable directory found on PATH. 1>&2
    exit /b 1
)

set "TARGET=!TARGET_DIR!\!BINARY_NAME!"
copy /y "!SOURCE!" "!TARGET!" >nul
echo Installed to: !TARGET!
