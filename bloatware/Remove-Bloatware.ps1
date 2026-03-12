# Title:       Remove-Bloatware.ps1
# Description: Interactively removes bloatware identified by Scan-Bloatware.ps1
# Target OS:   Windows 10/11
# Author:      Tekphreak Labs
# Usage:       .\Remove-Bloatware.ps1
#              .\Remove-Bloatware.ps1 -Force          (remove all without prompts)
#              .\Remove-Bloatware.ps1 -DryRun         (show what would be removed)

param(
    [string]$ReportPath = "$env:TEMP\bloatware-report.csv",
    [switch]$Force,
    [switch]$DryRun
)

. "$PSScriptRoot\..\lib\Write-Header.ps1"
. "$PSScriptRoot\..\lib\Confirm-Admin.ps1"

Write-Header -Title "Bloatware Remover" -Description "Uninstalls bloatware identified by Scan-Bloatware.ps1"

if (-not $DryRun) { Confirm-Admin }

if (-not (Test-Path $ReportPath)) {
    Write-Error "Report not found: $ReportPath`nRun Scan-Bloatware.ps1 first."
    exit 1
}

$apps = Import-Csv -Path $ReportPath
if ($apps.Count -eq 0) {
    Write-Host "No bloatware entries in report." -ForegroundColor Green
    exit 0
}

$logPath = "$env:TEMP\bloatware-removal-log.txt"
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
Add-Content -Path $logPath -Value "`n=== OffShore Removal Session: $timestamp ==="

$removed = 0
$skipped = 0
$failed  = 0

foreach ($app in $apps) {
    Write-Host "-------------------------------------------" -ForegroundColor DarkGray
    Write-Host "  App:       $($app.DisplayName)" -ForegroundColor Yellow
    Write-Host "  Version:   $($app.Version)" -ForegroundColor Gray
    Write-Host "  Publisher: $($app.Publisher)" -ForegroundColor Gray
    Write-Host ""

    if ($DryRun) {
        Write-Host "  [DryRun] Would uninstall: $($app.DisplayName)" -ForegroundColor Yellow
        continue
    }

    if (-not $Force) {
        $choice = Read-Host "  [Y] Remove  [S] Skip  [Q] Quit"
        if ($choice -eq "Q" -or $choice -eq "q") {
            Write-Host "Quitting." -ForegroundColor Gray
            break
        }
        if ($choice -ne "Y" -and $choice -ne "y") {
            Write-Host "  Skipped." -ForegroundColor Gray
            Add-Content -Path $logPath -Value "  SKIPPED: $($app.DisplayName)"
            $skipped++
            continue
        }
    }

    $uninstallStr = $app.UninstallString
    if (-not $uninstallStr) {
        Write-Warning "  No uninstall string found for $($app.DisplayName). Skipping."
        Add-Content -Path $logPath -Value "  NO_UNINSTALL_STRING: $($app.DisplayName)"
        $skipped++
        continue
    }

    try {
        Write-Host "  Uninstalling..." -ForegroundColor Cyan
        if ($uninstallStr -match "MsiExec") {
            # MSI uninstaller — extract GUID and run silently
            $guid = [regex]::Match($uninstallStr, '\{[^}]+\}').Value
            if ($guid) {
                Start-Process "msiexec.exe" -ArgumentList "/X$guid /quiet /norestart" -Wait -NoNewWindow
            } else {
                Start-Process "cmd.exe" -ArgumentList "/c $uninstallStr" -Wait -NoNewWindow
            }
        } else {
            # EXE uninstaller — run as-is
            Start-Process "cmd.exe" -ArgumentList "/c $uninstallStr" -Wait -NoNewWindow
        }
        Write-Host "  Removed: $($app.DisplayName)" -ForegroundColor Green
        Add-Content -Path $logPath -Value "  REMOVED: $($app.DisplayName)"
        $removed++
    } catch {
        Write-Warning "  Failed to remove $($app.DisplayName): $_"
        Add-Content -Path $logPath -Value "  FAILED: $($app.DisplayName) | $_"
        $failed++
    }
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Done. Removed: $removed  Skipped: $skipped  Failed: $failed" -ForegroundColor Cyan
Write-Host "  Log: $logPath" -ForegroundColor Gray
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
