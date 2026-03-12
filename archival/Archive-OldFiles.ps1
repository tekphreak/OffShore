# Title:       Archive-OldFiles.ps1
# Description: Compresses files older than N days into a ZIP archive
# Target OS:   Windows 10/11 (requires PowerShell 5+)
# Author:      Tekphreak Labs
# Usage:       .\Archive-OldFiles.ps1 -TargetDir "C:\Users\You\Downloads" -DaysOld 180
#              .\Archive-OldFiles.ps1 -TargetDir "C:\Users\You\Downloads" -DaysOld 365 -DeleteAfterArchive

param(
    [Parameter(Mandatory=$true)]
    [string]$TargetDir,
    [int]$DaysOld = 365,
    [string]$ArchiveDir = "",
    [switch]$DeleteAfterArchive,
    [switch]$WhatIf
)

. "$PSScriptRoot\..\lib\Write-Header.ps1"
Write-Header -Title "Archive Old Files" -Description "Compresses files older than $DaysOld days into a ZIP"

if (-not (Test-Path $TargetDir)) {
    Write-Error "Directory not found: $TargetDir"
    exit 1
}

if ($ArchiveDir -eq "") { $ArchiveDir = Join-Path $TargetDir "Archives" }

$cutoff = (Get-Date).AddDays(-$DaysOld)
$oldFiles = Get-ChildItem -Path $TargetDir -File | Where-Object { $_.LastWriteTime -lt $cutoff }

if ($oldFiles.Count -eq 0) {
    Write-Host "No files older than $DaysOld days found in $TargetDir" -ForegroundColor Green
    exit 0
}

$totalSize = ($oldFiles | Measure-Object -Property Length -Sum).Sum
$totalSizeMB = [math]::Round($totalSize / 1MB, 2)

Write-Host "Found $($oldFiles.Count) files older than $DaysOld days ($totalSizeMB MB)" -ForegroundColor Yellow
Write-Host ""

if ($WhatIf) {
    $oldFiles | ForEach-Object { Write-Host "[WhatIf] Would archive: $($_.Name)" -ForegroundColor Yellow }
    Write-Host ""
    Write-Host "(Dry run - no files were archived)" -ForegroundColor Yellow
    exit 0
}

$confirm = Read-Host "Archive these files? (Y/N)"
if ($confirm -ne "Y" -and $confirm -ne "y") {
    Write-Host "Cancelled." -ForegroundColor Gray
    exit 0
}

if (-not (Test-Path $ArchiveDir)) {
    New-Item -ItemType Directory -Path $ArchiveDir | Out-Null
}

$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm"
$archiveName = "Archive_$timestamp.zip"
$archivePath = Join-Path $ArchiveDir $archiveName
$logPath = Join-Path $ArchiveDir "archive-log.txt"

Write-Host "Creating archive: $archivePath" -ForegroundColor Cyan

$tempDir = Join-Path $env:TEMP "OffShore_Archive_$timestamp"
New-Item -ItemType Directory -Path $tempDir | Out-Null

foreach ($file in $oldFiles) {
    Copy-Item -Path $file.FullName -Destination $tempDir
}

Compress-Archive -Path "$tempDir\*" -DestinationPath $archivePath -CompressionLevel Optimal
Remove-Item -Path $tempDir -Recurse -Force

$logEntry = "[$timestamp] Archived $($oldFiles.Count) files ($totalSizeMB MB) -> $archiveName"
Add-Content -Path $logPath -Value $logEntry

if ($DeleteAfterArchive) {
    Write-Host "Deleting originals..." -ForegroundColor Yellow
    $oldFiles | ForEach-Object { Remove-Item -Path $_.FullName -Force }
    Add-Content -Path $logPath -Value "  Originals deleted."
}

Write-Host ""
Write-Host "Done. Archive saved to: $archivePath" -ForegroundColor Green
Write-Host "Log: $logPath" -ForegroundColor Gray
Write-Host ""
