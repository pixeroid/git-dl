@echo off
setlocal EnableDelayedExpansion

set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=!SCRIPT_DIR:~0,-1!"
set "GIT_DL=!SCRIPT_DIR!\git-dl.bat"
set /a PASS=0
set /a FAIL=0

goto :main

:pass
echo   PASS: %~1
set /a PASS+=1
exit /b 0

:fail
echo   FAIL: %~1
set /a FAIL+=1
exit /b 0

rem run_test <description> <expected_path> <expect_exists: 0|1> [git-dl-arg]
rem When git-dl-arg is omitted, git-dl is called with no arguments.
:run_test
setlocal
set "DESCRIPTION=%~1"
set "EXPECTED_PATH=%~2"
set "EXPECT_EXISTS=%~3"
set "GIT_DL_ARG=%~4"

set "TMPDIR=%TEMP%\git-dl-test-%RANDOM%"
mkdir "!TMPDIR!"

set "RESULT=0"
pushd "!TMPDIR!"
if "!GIT_DL_ARG!"=="" (
    call "!GIT_DL!" >nul 2>&1 || set "RESULT=1"
) else (
    call "!GIT_DL!" "!GIT_DL_ARG!" >nul 2>&1 || set "RESULT=1"
)
popd

if "!EXPECT_EXISTS!"=="1" (
    if exist "!TMPDIR!\!EXPECTED_PATH!" (
        endlocal & call :pass "%DESCRIPTION%"
    ) else (
        endlocal & call :fail "%DESCRIPTION%"
    )
) else (
    if "!RESULT!"=="1" (
        endlocal & call :pass "%DESCRIPTION%"
    ) else (
        endlocal & call :fail "%DESCRIPTION%"
    )
)

rd /s /q "!TMPDIR!" 2>nul
exit /b 0

:main
echo.
echo === Checking git-dl exists ===
if exist "!GIT_DL!" (
    call :pass "git-dl.bat exists"
) else (
    call :fail "git-dl.bat not found"
)

echo.
echo === Use case 1: Download full repo ===
call :run_test "Downloads repo into folder named after the repo" "dotenv" 1 "https://github.com/motdotla/dotenv"
call :run_test "Repo folder contains expected top-level file" "dotenv\README.md" 1 "https://github.com/motdotla/dotenv"

echo.
echo === Use case 2: Download specific folder ===
call :run_test "Downloads folder into directory named after the folder" "dotenv" 1 "https://github.com/motdotla/dotenv/tree/master/skills/dotenv"
call :run_test "Downloaded folder contains expected files" "dotenv\SKILL.md" 1 "https://github.com/motdotla/dotenv/tree/master/skills/dotenv"

echo.
echo === Use case 3: Download specific file ===
call :run_test "Downloads file directly into CWD" "SKILL.md" 1 "https://github.com/motdotla/dotenv/blob/master/skills/dotenv/SKILL.md"

echo.
echo === Conflict handling ===

set "TMPDIR=%TEMP%\git-dl-test-%RANDOM%"
mkdir "!TMPDIR!\dotenv"
set "RESULT=0"
pushd "!TMPDIR!"
call "!GIT_DL!" "https://github.com/motdotla/dotenv" >nul 2>&1 || set "RESULT=1"
popd
if "!RESULT!"=="1" (
    call :pass "Exits with error when target folder already exists"
) else (
    call :fail "Should error when target folder already exists"
)
rd /s /q "!TMPDIR!" 2>nul

set "TMPDIR=%TEMP%\git-dl-test-%RANDOM%"
mkdir "!TMPDIR!"
copy /y nul "!TMPDIR!\SKILL.md" >nul
set "RESULT=0"
pushd "!TMPDIR!"
call "!GIT_DL!" "https://github.com/motdotla/dotenv/blob/master/skills/dotenv/SKILL.md" >nul 2>&1 || set "RESULT=1"
popd
if "!RESULT!"=="1" (
    call :pass "Exits with error when target file already exists"
) else (
    call :fail "Should error when target file already exists"
)
rd /s /q "!TMPDIR!" 2>nul

echo.
echo === Script safety ===
findstr /r /c:"\bdel\b" "!GIT_DL!" >nul 2>&1
if errorlevel 1 (
    call :pass "Script contains no 'del' command"
) else (
    call :fail "Script contains 'del' command"
)

echo.
echo === No arguments ===
call :run_test "Exits with non-zero when called with no arguments" "" 0

echo.
echo ================================
echo   Results: !PASS! passed, !FAIL! failed
echo ================================
echo.

if !FAIL! equ 0 ( exit /b 0 ) else ( exit /b 1 )
