@echo off
echo BUILD ONLY - Native Scan List tick suppression and matching Scan Zone tick.
echo No radio connection or firmware write.
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -ExecutionPolicy Bypass -File "%~dp0build_csky.ps1" -IncludeScanTickFix
pause
