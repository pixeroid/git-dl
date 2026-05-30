@echo off
setlocal EnableDelayedExpansion

set "URL="

if "%~1"=="" goto usage
if "%~1"=="-h" goto usage
if "%~1"=="--help" goto usage

:parse_args
if "%~1"=="" goto args_done
set "ARG=%~1"
if "!ARG:~0,1!"=="-" (
    echo Error: Unknown flag: %~1 1>&2
    exit /b 1
)
if defined URL (
    echo Error: Too many arguments. 1>&2
    exit /b 1
)
set "URL=%~1"
shift
goto parse_args
:args_done

if not defined URL goto usage

where git >nul 2>&1 || (
    echo Error: git is not available. 1>&2
    exit /b 1
)

rem Strip trailing backslash or forward slash
:strip_trailing_slash
if "!URL:~-1!"=="/" set "URL=!URL:~0,-1!" & goto strip_trailing_slash
if "!URL:~-1!"=="\" set "URL=!URL:~0,-1!" & goto strip_trailing_slash

rem Strip .git suffix
if "!URL:~-4!"==".git" set "URL=!URL:~0,-4!"

rem Parse URL: https://github.com/OWNER/REPO[/(tree|blob)/BRANCH[/SUBPATH]]
rem Extract everything after https://github.com/
set "PATH_PART="
for /f "tokens=1,* delims=/" %%A in ("!URL:https://github.com/=!") do (
    set "PATH_PART=%%A/%%B"
    set "REMAINING=%%B"
)

rem Re-parse with proper token handling
set "OWNER="
set "REPO="
set "TYPE="
set "BRANCH="
set "SUBPATH="

rem Check URL starts with https://github.com/
echo !URL! | findstr /b /c:"https://github.com/" >nul 2>&1
if errorlevel 1 (
    echo Error: Unrecognised GitHub URL: !URL! 1>&2
    exit /b 1
)

rem Strip the prefix to get the path segments
set "AFTER_HOST=!URL:https://github.com/=!"

rem Extract OWNER (first segment)
for /f "tokens=1,* delims=/" %%A in ("!AFTER_HOST!") do (
    set "OWNER=%%A"
    set "REST1=%%B"
)

if not defined OWNER (
    echo Error: Unrecognised GitHub URL: !URL! 1>&2
    exit /b 1
)
if not defined REST1 (
    echo Error: Unrecognised GitHub URL: !URL! 1>&2
    exit /b 1
)

rem Extract REPO (second segment)
for /f "tokens=1,* delims=/" %%A in ("!REST1!") do (
    set "REPO=%%A"
    set "REST2=%%B"
)

if not defined REPO (
    echo Error: Unrecognised GitHub URL: !URL! 1>&2
    exit /b 1
)

rem If nothing after REPO, it's a plain repo URL
if not defined REST2 (
    set "MODE=repo"
    set "TARGET=!REPO!"
    goto download
)

rem Extract TYPE (tree or blob)
for /f "tokens=1,* delims=/" %%A in ("!REST2!") do (
    set "TYPE=%%A"
    set "REST3=%%B"
)

if "!TYPE!"=="blob" (
    set "MODE=file"
) else if "!TYPE!"=="tree" (
    set "MODE=folder"
) else (
    echo Error: Unrecognised GitHub URL: !URL! 1>&2
    exit /b 1
)

if not defined REST3 (
    echo Error: URL must include a branch name after %TYPE%. 1>&2
    exit /b 1
)

rem Extract BRANCH (first segment of REST3)
for /f "tokens=1,* delims=/" %%A in ("!REST3!") do (
    set "BRANCH=%%A"
    set "SUBPATH=%%B"
)

rem Strip trailing slash from SUBPATH if any
if defined SUBPATH (
    :strip_subpath_slash
    if "!SUBPATH:~-1!"=="/" set "SUBPATH=!SUBPATH:~0,-1!" & goto strip_subpath_slash
)

if "!MODE!"=="file" (
    if not defined SUBPATH (
        echo Error: File URL must include a file path after the branch name. 1>&2
        exit /b 1
    )
)
if "!MODE!"=="folder" (
    if not defined SUBPATH (
        echo Error: Folder URL must include a folder path after the branch name. 1>&2
        exit /b 1
    )
)

rem Derive TARGET from the last path segment of SUBPATH
for %%F in ("!SUBPATH:/=\!") do set "TARGET=%%~nxF"

:download
set "REMOTE=https://github.com/!OWNER!/!REPO!.git"

if "!MODE!"=="repo" (
    if exist "!TARGET!" (
        echo Error: '!TARGET!' already exists in the current directory. Remove it first. 1>&2
        exit /b 1
    )
    if defined BRANCH (
        git clone --depth=1 --branch "!BRANCH!" "!REMOTE!" "!TARGET!"
    ) else (
        git clone --depth=1 "!REMOTE!" "!TARGET!"
    )
    git -C "!TARGET!" remote remove origin
    echo Downloaded to: !TARGET!
    exit /b 0
)

rem folder or file: need a temp workspace
set "WORKDIR=%TEMP%\git-dl-%RANDOM%"
mkdir "!WORKDIR!"
set "LOCAL_CLONE=!WORKDIR!\repo"

if defined BRANCH (
    git clone --depth=1 --filter=blob:none --sparse --branch "!BRANCH!" "!REMOTE!" "!LOCAL_CLONE!"
) else (
    git clone --depth=1 --filter=blob:none --sparse "!REMOTE!" "!LOCAL_CLONE!"
)

if "!MODE!"=="folder" (
    if exist "!TARGET!" (
        echo Error: '!TARGET!' already exists in the current directory. Remove it first. 1>&2
        exit /b 1
    )
    git -C "!LOCAL_CLONE!" sparse-checkout set "!SUBPATH!"
    set "SUBPATH_LOCAL=!SUBPATH:/=\!"
    if not exist "!LOCAL_CLONE!\!SUBPATH_LOCAL!" (
        echo Error: Path '!SUBPATH!' not found in the repository. 1>&2
        exit /b 1
    )
    move "!LOCAL_CLONE!\!SUBPATH_LOCAL!" "!TARGET!" >nul
)

if "!MODE!"=="file" (
    if exist "!TARGET!" (
        echo Error: '!TARGET!' already exists in the current directory. Remove it first. 1>&2
        exit /b 1
    )
    git -C "!LOCAL_CLONE!" sparse-checkout set --no-cone "!SUBPATH!"
    set "SUBPATH_LOCAL=!SUBPATH:/=\!"
    if not exist "!LOCAL_CLONE!\!SUBPATH_LOCAL!" (
        echo Error: File '!SUBPATH!' not found in the repository. 1>&2
        exit /b 1
    )
    move "!LOCAL_CLONE!\!SUBPATH_LOCAL!" "!TARGET!" >nul
)

echo Downloaded to: !TARGET!
exit /b 0

:usage
echo Usage: git-dl ^<github-url^>
echo.
echo   Downloads a GitHub repo, folder, or file without cloning.
exit /b 1
