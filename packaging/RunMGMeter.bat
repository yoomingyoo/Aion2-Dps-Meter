@echo off
setlocal
wscript.exe "%~dp0RunMGMeter.vbs"
exit /b %errorlevel%
