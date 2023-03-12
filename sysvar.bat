@echo off
setlocal EnableDelayedExpansion
set output=output.txt
set output_dir=%USERPROFILE%\Desktop
echo SYSTEMDRIVE:...... %SYSTEMDRIVE% > %output_dir%\SysVar.txt
echo SYSTEMROOT:....... %SYSTEMROOT% >> %output_dir%\SysVar.txt
echo USERPROFILE:...... %USERPROFILE% >> %output_dir%\SysVar.txt
echo PROGRAMFILES:..... %PROGRAMFILES% >> %output_dir%\SysVar.txt
echo PROGRAMFILES(X86): %PROGRAMFILES(x86)% >> %output_dir%\SysVar.txt
echo APPDATA:.......... %APPDATA% >> %output_dir%\SysVar.txt
echo LOCALAPPDATA:..... %LOCALAPPDATA% >> %output_dir%\SysVar.txt
echo TEMP:............. %TEMP% >> %output_dir%\SysVar.txt
echo TMP:.............. %TMP% >> %output_dir%\SysVar.txt
echo USERPROFILE:...... %USERPROFILE% >> %output_dir%\SysVar.txt
echo PUBLIC:........... %PUBLIC% >> %output_dir%\SysVar.txt
echo WINDIR:........... %WINDIR% >> %output_dir%\SysVar.txt
echo. >> %output_dir%\SysVar.txt
echo. >> %output_dir%\SysVar.txt
echo. >> %output_dir%\SysVar.txt
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" (
    echo This is a 64-bit version of Windows.>> %output_dir%\SysVar.txt
) else (
    echo This is a 32-bit version of Windows.>> %output_dir%\SysVar.txt
)

del /q /f /s %TEMP%\*.* >nul 2>&1
del /q /f /s %TMP%\*.* >nul 2>&1
echo Copyright(r) 2023 Tekphreak Labs >> %output_dir%\SysVar.txt
Type %output%
