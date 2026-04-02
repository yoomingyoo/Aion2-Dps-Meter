MGMeter Portable Package
========================

1. Extract this zip to any folder you want.
2. Make sure Npcap is installed on the machine.
3. Run RunMGMeter.bat.
4. Accept the Windows UAC prompt so the app starts with administrator rights.

Notes
-----
- The package includes its own Java runtime (copied from the JDK used at build time).
- RunMGMeter.bat uses a bundled VBS launcher (no console window).
- Config and debug logs are stored under %LOCALAPPDATA%\MGMeter.
- Debug logs are written only when debug logging is enabled in the app UI.
- If the launcher fails, check %LOCALAPPDATA%\MGMeter\logs\launcher-error.log.
