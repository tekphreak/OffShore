@echo off
setlocal EnableDelayedExpansion

REM Check if ip.txt exists in the temp folder
set "filename=%TEMP%\ip.txt"
if exist "%filename%" (
    echo Previous IP address found:
    type "%filename%"
    exit /b
)

REM Download curl if it doesn't exist
if not exist curl.exe (
    curl.exe --version > nul 2>&1
    if !errorlevel! neq 0 (
        echo "curl" command not found. Downloading curl...
        powershell -Command "Invoke-WebRequest -Uri 'https://curl.haxx.se/download/curl-7.80.0-win64-mingw.zip' -OutFile 'curl.zip'"
        powershell -Command "Expand-Archive -Path '.\curl.zip' -DestinationPath '.'"
        del curl.zip
    )
)

REM Get external IP address using curl
for /f "delims=" %%a in ('curl -s https://ifconfig.me/ip') do set ip=%%a

REM Check if ip.txt exists in the temp folder and determine next available filename
set "filename=%TEMP%\ip.txt"
for /l %%i in (2, 1, 10) do (
    if exist "!filename!" (
        set "filename=%TEMP%\ip%%i.txt"
    ) else (
        goto next
    )
)
:next

REM Rename any existing ip.txt file
if exist "%TEMP%\ip.txt" (
    ren "%TEMP%\ip.txt" "%filename%"
)

REM Write IP address to a file in the temp folder
echo %ip% > "%TEMP%\ip.txt"

echo Your external IPv4 address is %ip%
TIMEOUT /T 2 /NOBREAK >nul
