# Title:       Scan-Bloatware.ps1
# Description: Scans installed applications against a known bloatware list and generates a report
# Target OS:   Windows 10/11
# Author:      Tekphreak Labs
# Usage:       .\Scan-Bloatware.ps1
#              .\Scan-Bloatware.ps1 -ListPath ".\my-list.txt" -ReportPath "C:\Temp\report.txt"

param(
    [string]$ListPath = "$PSScriptRoot\bloatware-list.txt",
    [string]$ReportPath = "$env:TEMP\bloatware-report.csv"
)

. "$PSScriptRoot\..\lib\Write-Header.ps1"
Write-Header -Title "Bloatware Scanner" -Description "Scanning installed apps against known bloatware list"

if (-not (Test-Path $ListPath)) {
    Write-Error "Bloatware list not found: $ListPath"
    exit 1
}

# Load bloatware list (skip comments and blank lines)
$bloatwareTerms = Get-Content $ListPath |
    Where-Object { $_ -notmatch '^\s*#' -and $_ -match '\S' } |
    ForEach-Object { $_.Trim() }

Write-Host "Loaded $($bloatwareTerms.Count) bloatware definitions." -ForegroundColor Gray
Write-Host "Scanning installed applications..." -ForegroundColor Gray
Write-Host ""

# Scan all three registry Uninstall hives
$regPaths = @(
    'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*',
    'HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
    'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
)

$installed = $regPaths | ForEach-Object {
    Get-ItemProperty $_ -ErrorAction SilentlyContinue
} | Where-Object { $_.DisplayName -match '\S' }

# Match against bloatware list
$found = @()
foreach ($term in $bloatwareTerms) {
    $matches = $installed | Where-Object { $_.DisplayName -match [regex]::Escape($term) }
    foreach ($app in $matches) {
        $found += [PSCustomObject]@{
            DisplayName     = $app.DisplayName
            Version         = $app.DisplayVersion
            Publisher       = $app.Publisher
            InstallDate     = $app.InstallDate
            UninstallString = $app.UninstallString
            MatchedTerm     = $term
        }
    }
}

# Deduplicate by DisplayName
$found = $found | Sort-Object DisplayName -Unique

if ($found.Count -eq 0) {
    Write-Host "No bloatware found. Your system looks clean!" -ForegroundColor Green
    exit 0
}

# Display results
Write-Host "FOUND $($found.Count) potential bloatware application(s):" -ForegroundColor Red
Write-Host ""
foreach ($app in $found) {
    Write-Host "  [FOUND] $($app.DisplayName)" -ForegroundColor Yellow
    Write-Host "          Version:   $($app.Version)" -ForegroundColor Gray
    Write-Host "          Publisher: $($app.Publisher)" -ForegroundColor Gray
    Write-Host "          Installed: $($app.InstallDate)" -ForegroundColor Gray
    Write-Host ""
}

# Export CSV for Remove-Bloatware.ps1
$found | Export-Csv -Path $ReportPath -NoTypeInformation
Write-Host "Report saved to: $ReportPath" -ForegroundColor Cyan
Write-Host "Run Remove-Bloatware.ps1 to interactively uninstall these apps." -ForegroundColor Cyan
Write-Host ""
