Option Explicit

Dim shell, appShell, fso, appRoot, javaHome, javawExe, appLauncher, logDir, launchLog, cmd
Set shell = CreateObject("WScript.Shell")
Set appShell = CreateObject("Shell.Application")
Set fso = CreateObject("Scripting.FileSystemObject")

appRoot = fso.GetParentFolderName(WScript.ScriptFullName)
javaHome = appRoot & "\runtime"
javawExe = javaHome & "\bin\javaw.exe"
appLauncher = appRoot & "\app\bin\MGMeter.bat"
Dim elevatedCmd
elevatedCmd = appRoot & "\RunMGMeterElevated.cmd"

logDir = shell.ExpandEnvironmentStrings("%LOCALAPPDATA%") & "\MGMeter\logs"
launchLog = logDir & "\launcher-error.log"

If Not fso.FolderExists(logDir) Then
    fso.CreateFolder(shell.ExpandEnvironmentStrings("%LOCALAPPDATA%") & "\MGMeter")
    fso.CreateFolder(logDir)
End If

If Not fso.FileExists(javawExe) Then
    shell.Popup "Bundled runtime was not found:" & vbCrLf & javawExe, 0, "MGMeter", 16
    WScript.Quit 1
End If

If Not fso.FileExists(appLauncher) Then
    shell.Popup "App launcher was not found:" & vbCrLf & appLauncher, 0, "MGMeter", 16
    WScript.Quit 1
End If

If Not fso.FileExists(elevatedCmd) Then
    shell.Popup "Elevated launcher was not found:" & vbCrLf & elevatedCmd, 0, "MGMeter", 16
    WScript.Quit 1
End If

' Run elevated, hidden.
appShell.ShellExecute elevatedCmd, "", appRoot, "runas", 0
