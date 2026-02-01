' Build GBA Project
Option Explicit

Function GetRootPath()
    Dim fso
    Set fso = CreateObject("Scripting.FileSystemObject")
    GetRootPath = fso.GetParentFolderName(fso.GetParentFolderName(WScript.ScriptFullName))
End Function

Function GetProjectsPath()
    Dim configPath, projectsPath, file, line, fso
    Set fso = CreateObject("Scripting.FileSystemObject")
    
    ' Default projects path
    projectsPath = GetRootPath() & "\Projects"
    
    ' Try to read from config.ini
    configPath = GetRootPath() & "\config.ini"
    
    If fso.FileExists(configPath) Then
        Set file = fso.OpenTextFile(configPath, 1)
        
        Do While Not file.AtEndOfStream
            line = Trim(file.ReadLine)
            If InStr(1, line, "PROJECTS_PATH=", vbTextCompare) = 1 Then
                projectsPath = Trim(Mid(line, InStr(line, "=") + 1))
                Exit Do
            End If
        Loop
        
        file.Close
    End If
    
    GetProjectsPath = projectsPath
End Function

Dim fso, shell, ws
Set fso = CreateObject("Scripting.FileSystemObject")
Set shell = CreateObject("WScript.Shell")
Set ws = CreateObject("WScript.Shell")

' Show project selection
Dim projectsPath, projectPath, projectName
projectsPath = GetProjectsPath()

If Not fso.FolderExists(projectsPath) Then
    MsgBox "Projects folder not found!", vbCritical
    WScript.Quit
End If

' Get list of projects - FIXED version
Dim folder, subFolder, projectList, i, selectedPath
Set folder = fso.GetFolder(projectsPath)

projectList = "Select project to build:" & vbCrLf & vbCrLf
i = 0

' Store project paths in a Dictionary
Dim projectDict
Set projectDict = CreateObject("Scripting.Dictionary")

For Each subFolder In folder.SubFolders
    i = i + 1
    projectList = projectList & i & ". " & subFolder.Name & vbCrLf
    projectDict.Add CStr(i), subFolder.Path
Next

If i = 0 Then
    MsgBox "No projects found in: " & projectsPath, vbExclamation
    WScript.Quit
End If

Dim choice
choice = InputBox(projectList, "Build Project", "1")

If choice = "" Or Not IsNumeric(choice) Then
    WScript.Quit
End If

' Get selected project path
If projectDict.Exists(CStr(choice)) Then
    projectPath = projectDict(CStr(choice))
Else
    MsgBox "Invalid selection!", vbExclamation
    WScript.Quit
End If

projectName = fso.GetFolder(projectPath).Name

' Check if build.bat exists
If Not fso.FileExists(projectPath & "\build.bat") Then
    MsgBox "build.bat not found in project!" & vbCrLf & _
           "This project may be using old structure.", vbExclamation
    ' Try alternative: check for Makefile
    If fso.FileExists(projectPath & "\Makefile") Then
        If MsgBox("Found Makefile. Try to build using make directly?", vbYesNo + vbQuestion) = vbYes Then
            shell.CurrentDirectory = projectPath
            shell.Run "cmd /c make", 1, True
        End If
    End If
    WScript.Quit
End If

' Run build.bat in the project folder
shell.CurrentDirectory = projectPath
shell.Run "build.bat", 1, True