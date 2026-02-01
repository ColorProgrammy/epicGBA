' Open GBA Project
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

Dim fso, shell
Set fso = CreateObject("Scripting.FileSystemObject")
Set shell = CreateObject("WScript.Shell")

' Show project selection
Dim projectsPath, projectPath, projectName
projectsPath = GetProjectsPath()

If Not fso.FolderExists(projectsPath) Then
    MsgBox "Projects folder not found!", vbCritical
    WScript.Quit
End If

' Get list of projects - FIXED version
Dim folder, subFolder, projectList, i
Set folder = fso.GetFolder(projectsPath)

projectList = "Select project to open:" & vbCrLf & vbCrLf
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
choice = InputBox(projectList, "Open Project", "1")

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

' Show options for opening
Dim actionChoice
actionChoice = InputBox( _
    "Project: " & projectName & vbCrLf & vbCrLf & _
    "Select action:" & vbCrLf & _
    "1. Open project folder" & vbCrLf & _
    "2. Open main.c in Notepad" & vbCrLf & _
    "3. Open in Visual Studio Code" & vbCrLf & _
    "4. Open build.bat" & vbCrLf & _
    "5. Open Makefile", _
    "Open Project", "1")

Select Case actionChoice
    Case "1"
        ' Open project folder
        shell.Run "explorer.exe """ & projectPath & """"
        
    Case "2"
        ' Open main.c in Notepad
        Dim mainFile
        mainFile = projectPath & "\source\main.c"
        If fso.FileExists(mainFile) Then
            shell.Run "notepad.exe """ & mainFile & """"
        Else
            MsgBox "main.c not found in project!", vbExclamation
        End If
        
    Case "3"
        ' Try to open in VS Code
        On Error Resume Next
        shell.Run "code """ & projectPath & """"
        If Err.Number <> 0 Then
            MsgBox "Visual Studio Code not found!", vbExclamation
        End If
        On Error GoTo 0
        
    Case "4"
        ' Open build.bat
        Dim buildFile
        buildFile = projectPath & "\build.bat"
        If fso.FileExists(buildFile) Then
            shell.Run "notepad.exe """ & buildFile & """"
        Else
            MsgBox "build.bat not found!", vbExclamation
        End If
        
    Case "5"
        ' Open Makefile
        Dim makeFile
        makeFile = projectPath & "\Makefile"
        If fso.FileExists(makeFile) Then
            shell.Run "notepad.exe """ & makeFile & """"
        Else
            MsgBox "Makefile not found!", vbExclamation
        End If
        
    Case Else
        ' Default: open project folder
        shell.Run "explorer.exe """ & projectPath & """"
End Select