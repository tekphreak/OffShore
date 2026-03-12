# Title:       Sort-FilesByDate.ps1
# Description: Moves files into YYYY-MM subfolders based on last modified date
# Target OS:   Windows 10/11
# Author:      Tekphreak Labs
# Usage:       .\Sort-FilesByDate.ps1 -TargetDir "C:\Users\You\Downloads"
#              .\Sort-FilesByDate.ps1 -TargetDir "C:\Users\You\Downloads" -UseCreationDate -WhatIf

param(
    [Parameter(Mandatory=$true)]
    [string]$TargetDir,
    [switch]$UseCreationDate,
    [switch]$WhatIf
)

. "$PSScriptRoot\..\lib\Write-Header.ps1"
Write-Header -Title "Sort Files By Date" -Description "Organizes files into YYYY-MM subfolders"

if (-not (Test-Path $TargetDir)) {
    Write-Error "Directory not found: $TargetDir"
    exit 1
}

$dateLabel = if ($UseCreationDate) { "creation date" } else { "last modified date" }
Write-Host "Sorting by: $dateLabel" -ForegroundColor Gray
Write-Host ""

$counts = @{}
$files = Get-ChildItem -Path $TargetDir -File

foreach ($file in $files) {
    $date = if ($UseCreationDate) { $file.CreationTime } else { $file.LastWriteTime }
    $folder = $date.ToString("yyyy-MM")
    $destDir = Join-Path $TargetDir $folder

    if (-not $WhatIf -and -not (Test-Path $destDir)) {
        New-Item -ItemType Directory -Path $destDir | Out-Null
    }

    $dest = Join-Path $destDir $file.Name
    if ($WhatIf) {
        Write-Host "[WhatIf] Would move: $($file.Name) -> $folder\" -ForegroundColor Yellow
    } else {
        Move-Item -Path $file.FullName -Destination $dest -Force
    }

    $counts[$folder] = ($counts[$folder] ?? 0) + 1
}

Write-Host ""
Write-Host "--- Summary ---" -ForegroundColor Cyan
$total = 0
foreach ($month in ($counts.Keys | Sort-Object)) {
    Write-Host "  $month`: $($counts[$month]) files"
    $total += $counts[$month]
}
Write-Host "  Total: $total files" -ForegroundColor Green
if ($WhatIf) { Write-Host "  (Dry run - no files were moved)" -ForegroundColor Yellow }
Write-Host ""
