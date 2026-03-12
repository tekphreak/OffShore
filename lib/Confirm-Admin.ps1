# Title:       Confirm-Admin.ps1
# Description: Checks for administrator elevation; re-launches with elevation if needed
# Target OS:   Windows 10/11
# Author:      Tekphreak Labs

function Confirm-Admin {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Warning "This script requires administrator privileges. Relaunching as admin..."
        $scriptPath = $MyInvocation.ScriptName
        Start-Process powershell.exe -Verb RunAs -ArgumentList "-ExecutionPolicy Bypass -File `"$scriptPath`""
        exit
    }
}
