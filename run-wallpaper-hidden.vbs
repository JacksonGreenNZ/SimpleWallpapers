Option Explicit

Dim shell, fileSystem, scriptFolder, powerShell, scriptPath, command

Set shell = CreateObject("WScript.Shell")
Set fileSystem = CreateObject("Scripting.FileSystemObject")

scriptFolder = fileSystem.GetParentFolderName(WScript.ScriptFullName)
powerShell = shell.ExpandEnvironmentStrings("%WINDIR%") & "\System32\WindowsPowerShell\v1.0\powershell.exe"
If WScript.Arguments.Count > 0 Then
    scriptPath = WScript.Arguments(0)
Else
    scriptPath = fileSystem.BuildPath(scriptFolder, "wallpapers.ps1")
End If

command = """" & powerShell & """ -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File """ & scriptPath & """"

shell.Run command, 0, True
