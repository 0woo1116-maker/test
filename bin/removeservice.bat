@ECHO off
set NAME="ERS Reporting Server V8"
net stop %NAME%

"%~dp0JavaService.exe" -uninstall %NAME%