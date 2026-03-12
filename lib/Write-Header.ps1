# Title:       Write-Header.ps1
# Description: Shared banner/header function for OffShore scripts
# Target OS:   Windows 10/11
# Author:      Tekphreak Labs

function Write-Header {
    param(
        [string]$Title,
        [string]$Description
    )
    $line = "=" * 60
    Write-Host ""
    Write-Host $line -ForegroundColor Cyan
    Write-Host "  OffShore | $Title" -ForegroundColor Cyan
    Write-Host "  $Description" -ForegroundColor Gray
    Write-Host "  $(Get-Date -Format 'yyyy-MM-dd HH:mm')  |  $env:COMPUTERNAME" -ForegroundColor Gray
    Write-Host $line -ForegroundColor Cyan
    Write-Host ""
}
