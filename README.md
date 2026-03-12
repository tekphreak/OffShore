# OffShore

Automated file archival, organization, and system maintenance tools for Windows. Cleans up cluttered folders, identifies bloatware, and keeps your machine running efficiently.

## Modules

### File Archival & Organization — `archival/`

Run `archival/Run-Archival.bat` for an interactive menu.

| Script | Description |
|---|---|
| `Sort-FilesByType.ps1` | Moves files into category subfolders (Images, Documents, Videos, Audio, Archives, Code, Misc) |
| `Sort-FilesByDate.ps1` | Moves files into `YYYY-MM` date folders |
| `Archive-OldFiles.ps1` | Compresses files older than N days into a ZIP archive |
| `Clean-EmptyFolders.ps1` | Recursively removes empty directories |

All scripts support a `-WhatIf` dry-run mode — see exactly what will happen before anything moves.

### Bloatware Removal — `bloatware/`

Run `bloatware/Run-Bloatware.bat` as Administrator.

| Script | Description |
|---|---|
| `Scan-Bloatware.ps1` | Scans all registry Uninstall hives against a known bloatware list |
| `Remove-Bloatware.ps1` | Interactively removes identified bloatware — Y/S/Q per app |
| `bloatware-list.txt` | Editable list of 50+ known bloatware apps — add your own |

### System Utilities

| Script | Description |
|---|---|
| `sysvar.bat` | Dumps key Windows system variables to Desktop, clears TEMP |
| `all-sys-vars` | Dumps all environment variables to a text file |
| `IpAddress.bat` | Gets and saves your external IP address |
| `fix-win` | Runs `sfc /scannow` and `DISM /RestoreHealth` to repair Windows |
| `text-delimiter.ps1` | Splits text file lines by delimiters |

## Usage

### Organize a folder
```batch
archival\Run-Archival.bat
```

### Scan for and remove bloatware
```batch
REM Right-click → Run as Administrator
bloatware\Run-Bloatware.bat
```

### Dry-run a sort (no files moved)
```powershell
.\archival\Sort-FilesByType.ps1 -TargetDir "C:\Users\You\Downloads" -WhatIf
```

## Requirements

- Windows 10 / 11
- PowerShell 5+ (built in)
- Administrator rights (for bloatware removal only)

---

Built by [Tekphreak](https://github.com/tekphreak)
