@echo off
TITLE OffShore - File Archival and Organization
cls
setlocal EnableDelayedExpansion

echo ============================================================
echo   OffShore ^| File Archival and Organization
echo ============================================================
echo.

REM Check PowerShell is available
where powershell >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: PowerShell not found. This tool requires PowerShell 5+.
    pause
    exit /b 1
)

SET /P TARGET_DIR=Enter the directory to process:

if not exist "%TARGET_DIR%" (
    echo ERROR: Directory not found: %TARGET_DIR%
    pause
    exit /b 1
)

echo.
echo What would you like to do?
echo   1. Sort files by type (Images, Documents, Videos, etc.)
echo   2. Sort files by date (YYYY-MM folders)
echo   3. Archive files older than N days
echo   4. Clean up empty folders
echo   5. Full pipeline (sort by type, then archive old, then clean)
echo   6. Exit
echo.
SET /P CHOICE=Enter choice (1-6):

if "%CHOICE%"=="1" goto :sort_type
if "%CHOICE%"=="2" goto :sort_date
if "%CHOICE%"=="3" goto :archive
if "%CHOICE%"=="4" goto :clean
if "%CHOICE%"=="5" goto :full
if "%CHOICE%"=="6" goto :end
echo Invalid choice.
goto :end

:sort_type
echo.
SET /P DRYRUN=Dry run first? (Y/N):
if /i "%DRYRUN%"=="Y" (
    powershell.exe -ExecutionPolicy Bypass -File "%~dp0Sort-FilesByType.ps1" -TargetDir "%TARGET_DIR%" -WhatIf
) else (
    powershell.exe -ExecutionPolicy Bypass -File "%~dp0Sort-FilesByType.ps1" -TargetDir "%TARGET_DIR%"
)
goto :end

:sort_date
echo.
SET /P DRYRUN=Dry run first? (Y/N):
if /i "%DRYRUN%"=="Y" (
    powershell.exe -ExecutionPolicy Bypass -File "%~dp0Sort-FilesByDate.ps1" -TargetDir "%TARGET_DIR%" -WhatIf
) else (
    powershell.exe -ExecutionPolicy Bypass -File "%~dp0Sort-FilesByDate.ps1" -TargetDir "%TARGET_DIR%"
)
goto :end

:archive
echo.
SET /P DAYS=Archive files older than how many days? (default: 365):
if "%DAYS%"=="" set DAYS=365
SET /P DELETE=Delete originals after archiving? (Y/N):
if /i "%DELETE%"=="Y" (
    powershell.exe -ExecutionPolicy Bypass -File "%~dp0Archive-OldFiles.ps1" -TargetDir "%TARGET_DIR%" -DaysOld %DAYS% -DeleteAfterArchive
) else (
    powershell.exe -ExecutionPolicy Bypass -File "%~dp0Archive-OldFiles.ps1" -TargetDir "%TARGET_DIR%" -DaysOld %DAYS%
)
goto :end

:clean
echo.
powershell.exe -ExecutionPolicy Bypass -File "%~dp0Clean-EmptyFolders.ps1" -TargetDir "%TARGET_DIR%"
goto :end

:full
echo.
echo Running full pipeline on: %TARGET_DIR%
echo Step 1/3: Sort by type...
powershell.exe -ExecutionPolicy Bypass -File "%~dp0Sort-FilesByType.ps1" -TargetDir "%TARGET_DIR%"
echo Step 2/3: Archive files older than 365 days...
powershell.exe -ExecutionPolicy Bypass -File "%~dp0Archive-OldFiles.ps1" -TargetDir "%TARGET_DIR%" -DaysOld 365
echo Step 3/3: Clean empty folders...
powershell.exe -ExecutionPolicy Bypass -File "%~dp0Clean-EmptyFolders.ps1" -TargetDir "%TARGET_DIR%"
goto :end

:end
echo.
pause
