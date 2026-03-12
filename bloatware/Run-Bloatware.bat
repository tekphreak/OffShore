@echo off
TITLE OffShore - Bloatware Scanner and Remover
cls

REM Check for administrator privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: This tool must be run as Administrator.
    echo Right-click this file and select "Run as Administrator".
    pause
    exit /b 1
)

echo ============================================================
echo   OffShore ^| Bloatware Scanner and Remover
echo ============================================================
echo.
echo Step 1: Scanning installed applications...
echo.

powershell.exe -ExecutionPolicy Bypass -File "%~dp0Scan-Bloatware.ps1"

echo.
SET /P REMOVE=Proceed to removal? (Y/N):

if /i "%REMOVE%"=="Y" (
    echo.
    echo Step 2: Starting interactive removal...
    echo.
    powershell.exe -ExecutionPolicy Bypass -File "%~dp0Remove-Bloatware.ps1"
) else (
    echo.
    echo Removal skipped. You can run Remove-Bloatware.ps1 manually later.
)

echo.
pause
