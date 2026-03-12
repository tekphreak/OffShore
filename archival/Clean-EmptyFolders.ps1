# Title:       Clean-EmptyFolders.ps1
# Description: Recursively removes empty directories from a target path
# Target OS:   Windows 10/11
# Author:      Tekphreak Labs
# Usage:       .\Clean-EmptyFolders.ps1 -TargetDir "C:\Users\You\Downloads"
#              .\Clean-EmptyFolders.ps1 -TargetDir "C:\Users\You\Downloads" -WhatIf

param(
    [Parameter(Mandatory=$true)]
    [string]$TargetDir,
    [switch]$WhatIf
)

. "$PSScriptRoot\..\lib\Write-Header.ps1"
Write-Header -Title "Clean Empty Folders" -Description "Removes empty directories recursively"

if (-not (Test-Path $TargetDir)) {
    Write-Error "Directory not found: $TargetDir"
    exit 1
}

# Sort deepest folders first so nested empties are removed before their parents
$emptyDirs = Get-ChildItem -Path $TargetDir -Recurse -Directory |
    Where-Object { (Get-ChildItem -Path $_.FullName -Force) -eq $null } |
    Sort-Object { $_.FullName.Split('\').Count } -Descending

if ($emptyDirs.Count -eq 0) {
    Write-Host "No empty folders found in $TargetDir" -ForegroundColor Green
    exit 0
}

Write-Host "Found $($emptyDirs.Count) empty folder(s):" -ForegroundColor Yellow
$emptyDirs | ForEach-Object { Write-Host "  $($_.FullName)" -ForegroundColor Gray }
Write-Host ""

if ($WhatIf) {
    Write-Host "(Dry run - no folders were removed)" -ForegroundColor Yellow
    exit 0
}

$removed = 0
foreach ($dir in $emptyDirs) {
    try {
        Remove-Item -Path $dir.FullName -Force
        $removed++
    } catch {
        Write-Warning "Could not remove: $($dir.FullName)"
    }
}

Write-Host "Removed $removed empty folder(s)." -ForegroundColor Green
Write-Host ""
