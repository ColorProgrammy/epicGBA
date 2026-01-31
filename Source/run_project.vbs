' Run GBA Project in Emulator
Option Explicit

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

projectList = "Select project to run:" & vbCrLf & vbCrLf
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
choice = InputBox(projectList, "Run Project", "1")

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

' Check if ROM exists
Dim romPath
romPath = projectPath & "\" & projectName & ".gba"

If Not fso.FileExists(romPath) Then
    If MsgBox("ROM file not found!" & vbCrLf & _
              "File: " & projectName & ".gba" & vbCrLf & _
              "Compile project first?", vbYesNo + vbQuestion) = vbYes Then
        
        ' Try to compile first
        If fso.FileExists(projectPath & "\build.bat") Then
            shell.CurrentDirectory = projectPath
            shell.Run "build.bat", 1, True
        ElseIf fso.FileExists(projectPath & "\Makefile") Then
            shell.CurrentDirectory = projectPath
            shell.Run "cmd /c make", 1, True
        Else
            MsgBox "No build files found in project!", vbExclamation
            WScript.Quit
        End If
    Else
        WScript.Quit
    End If
    
    ' Check again after compilation attempt
    If Not fso.FileExists(romPath) Then
        MsgBox "ROM file still not found!" & vbCrLf & _
               "Build may have failed.", vbExclamation
        WScript.Quit
    End If
End If

' Try to run in mGBA
Dim mgbaPath, found, configPath, configFile, line
found = False

' First check config.ini for mGBA path
configPath = fso.GetParentFolderName(WScript.ScriptFullName) & "\config.ini"
If fso.FileExists(configPath) Then
    Set configFile = fso.OpenTextFile(configPath, 1)
    Do While Not configFile.AtEndOfStream
        line = Trim(configFile.ReadLine)
        If InStr(1, line, "MGBA=", vbTextCompare) = 1 Then
            mgbaPath = Trim(Mid(line, InStr(line, "=") + 1))
            found = True
            Exit Do
        End If
    Loop
    configFile.Close
End If

' If not found in config, check common locations
If Not found Then
    Dim paths, path
    paths = Array( _
        "C:\Program Files\mGBA\mGBA.exe", _
        "C:\Program Files (x86)\mGBA\mGBA.exe", _
        shell.ExpandEnvironmentStrings("%ProgramFiles%") & "\mGBA\mGBA.exe", _
        shell.ExpandEnvironmentStrings("%ProgramFiles(x86)%") & "\mGBA\mGBA.exe" _
    )
    
    For Each path In paths
        If fso.FileExists(path) Then
            mgbaPath = path
            found = True
            Exit For
        End If
    Next
End If

If found Then
    shell.Run Chr(34) & mgbaPath & Chr(34) & " " & Chr(34) & romPath & Chr(34)
Else
    MsgBox "mGBA emulator not found!" & vbCrLf & _
           "Please install mGBA from https://mgba.io/" & vbCrLf & _
           "or set the path in config.ini", vbCritical
End If

Function GetProjectsPath()
    Dim configPath, projectsPath, file, line
    
    ' Default projects path
    projectsPath = fso.GetParentFolderName(WScript.ScriptFullName) & "\Projects"
    
    ' Try to read from config.ini
    configPath = fso.GetParentFolderName(WScript.ScriptFullName) & "\config.ini"
    
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
