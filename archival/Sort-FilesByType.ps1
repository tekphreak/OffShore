# Title:       Sort-FilesByType.ps1
# Description: Moves files in a directory into category subfolders based on extension
# Target OS:   Windows 10/11
# Author:      Tekphreak Labs
# Usage:       .\Sort-FilesByType.ps1 -TargetDir "C:\Users\You\Downloads"
#              .\Sort-FilesByType.ps1 -TargetDir "C:\Users\You\Downloads" -WhatIf

param(
    [Parameter(Mandatory=$true)]
    [string]$TargetDir,
    [switch]$WhatIf
)

. "$PSScriptRoot\..\lib\Write-Header.ps1"
Write-Header -Title "Sort Files By Type" -Description "Organizes files into category subfolders"

if (-not (Test-Path $TargetDir)) {
    Write-Error "Directory not found: $TargetDir"
    exit 1
}

$typeMap = @{
    "Images"    = @(".jpg",".jpeg",".png",".gif",".bmp",".tiff",".webp",".heic",".svg",".ico")
    "Documents" = @(".pdf",".docx",".doc",".xlsx",".xls",".pptx",".ppt",".txt",".csv",".odt",".rtf",".md")
    "Videos"    = @(".mp4",".mkv",".avi",".mov",".wmv",".flv",".m4v",".webm")
    "Audio"     = @(".mp3",".flac",".wav",".aac",".ogg",".wma",".m4a",".opus")
    "Archives"  = @(".zip",".rar",".7z",".tar",".gz",".bz2",".xz")
    "Code"      = @(".ps1",".bat",".cmd",".py",".js",".ts",".html",".css",".sh",".json",".xml",".yaml",".yml")
    "Misc"      = @()
}

# Build reverse lookup: extension -> category
$extMap = @{}
foreach ($category in $typeMap.Keys) {
    foreach ($ext in $typeMap[$category]) {
        $extMap[$ext] = $category
    }
}

$counts = @{}
$files = Get-ChildItem -Path $TargetDir -File

foreach ($file in $files) {
    $ext = $file.Extension.ToLower()
    $category = if ($extMap.ContainsKey($ext)) { $extMap[$ext] } else { "Misc" }
    $destDir = Join-Path $TargetDir $category

    if (-not $WhatIf -and -not (Test-Path $destDir)) {
        New-Item -ItemType Directory -Path $destDir | Out-Null
    }

    $dest = Join-Path $destDir $file.Name
    if ($WhatIf) {
        Write-Host "[WhatIf] Would move: $($file.Name) -> $category\" -ForegroundColor Yellow
    } else {
        Move-Item -Path $file.FullName -Destination $dest -Force
    }

    $counts[$category] = ($counts[$category] ?? 0) + 1
}

Write-Host ""
Write-Host "--- Summary ---" -ForegroundColor Cyan
$total = 0
foreach ($cat in ($counts.Keys | Sort-Object)) {
    Write-Host "  $cat`: $($counts[$cat]) files"
    $total += $counts[$cat]
}
Write-Host "  Total: $total files" -ForegroundColor Green
if ($WhatIf) { Write-Host "  (Dry run - no files were moved)" -ForegroundColor Yellow }
Write-Host ""
