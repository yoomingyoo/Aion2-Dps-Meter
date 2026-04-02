@echo off
setlocal

cd /d "%~dp0"

set "APP_HOME=%~dp0"
set "JAVA_HOME=%APP_HOME%runtime"
set "JAVA_EXE=%JAVA_HOME%\\bin\\java.exe"
set "APP_LAUNCHER=%APP_HOME%app\\bin\\MGMeter.bat"

set "LOG_DIR=%LOCALAPPDATA%\\MGMeter\\logs"
set "LAUNCH_LOG=%LOG_DIR%\\launcher-error.log"

if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"

if not exist "%JAVA_EXE%" (
  echo Bundled runtime was not found: "%JAVA_EXE%" 1>>"%LAUNCH_LOG%" 2>&1
  start "" notepad.exe "%LAUNCH_LOG%"
  exit /b 1
)

if not exist "%APP_LAUNCHER%" (
  echo App launcher was not found: "%APP_LAUNCHER%" 1>>"%LAUNCH_LOG%" 2>&1
  start "" notepad.exe "%LAUNCH_LOG%"
  exit /b 1
)

call "%APP_LAUNCHER%" 1>>"%LAUNCH_LOG%" 2>&1
set "EXIT_CODE=%errorlevel%"
if not "%EXIT_CODE%"=="0" (
  start "" notepad.exe "%LAUNCH_LOG%"
)
exit /b %EXIT_CODE%
