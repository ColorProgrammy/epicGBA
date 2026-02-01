' SimpleGBA-IDE Main Menu
Option Explicit

Function GetRootPath()
    Dim fso
    Set fso = CreateObject("Scripting.FileSystemObject")
    GetRootPath = fso.GetParentFolderName(fso.GetParentFolderName(WScript.ScriptFullName))
End Function

Function GetConfigPath()
    GetConfigPath = GetRootPath() & "\config.ini"
End Function

Function GetProjectsPath()
    Dim configPath, path, line, file, fso
    Set fso = CreateObject("Scripting.FileSystemObject")
    
    ' По умолчанию - папка Projects в корне
    path = GetRootPath() & "\Projects"
    
    ' Пробуем прочитать из конфига
    configPath = GetConfigPath()
    If fso.FileExists(configPath) Then
        Set file = fso.OpenTextFile(configPath, 1)
        Do While Not file.AtEndOfStream
            line = Trim(file.ReadLine)
            If Left(line, 13) = "PROJECTS_PATH=" Then
                Dim tempPath
                tempPath = Mid(line, 14)
                ' Если путь относительный, делаем его абсолютным относительно корня
                If Not (Left(tempPath, 2) = "\\" Or Mid(tempPath, 2, 1) = ":") Then
                    If Left(tempPath, 1) = "." Then
                        ' Относительный путь
                        path = fso.BuildPath(GetRootPath(), tempPath)
                    Else
                        ' Относительный путь без точки
                        path = GetRootPath() & "\" & tempPath
                    End If
                Else
                    ' Абсолютный путь
                    path = tempPath
                End If
                Exit Do
            End If
        Loop
        file.Close
    End If
    
    ' Создаем папку если не существует
    If Not fso.FolderExists(path) Then
        On Error Resume Next
        fso.CreateFolder path
        On Error GoTo 0
    End If
    
    GetProjectsPath = path
End Function

Dim fso, shell, configPath, configExists
Set fso = CreateObject("Scripting.FileSystemObject")
Set shell = CreateObject("WScript.Shell")

configPath = GetConfigPath()
configExists = fso.FileExists(configPath)

If Not configExists Then
    MsgBox "Configuration not found. Running setup...", vbInformation
    shell.Run Chr(34) & GetRootPath() & "\Source\setup_ide.vbs" & Chr(34)
    WScript.Quit
End If

MainMenu

Sub MainMenu()
    Dim choice
    
    Do
        choice = InputBox( _
            "=== SIMPLE GBA IDE === " & vbCrLf & _
            "1. Create new project" & vbCrLf & _
            "2. Open project" & vbCrLf & _
            "3. Build project" & vbCrLf & _
            "4. Run in emulator" & vbCrLf & _
            "5. Build and run" & vbCrLf & _
            "6. IDE Settings" & vbCrLf & _
            "7. Help" & vbCrLf & _
            "8. Exit" & vbCrLf & vbCrLf & _
            "Select action:", _
            "SimpleGBA-IDE", "1")
        
        If choice = "" Then Exit Do
        
        Select Case choice
            Case "1"
                shell.Run Chr(34) & GetRootPath() & "\Source\create_project.vbs" & Chr(34)
            Case "2"
                shell.Run Chr(34) & GetRootPath() & "\Source\open_project.vbs" & Chr(34)
            Case "3"
                shell.Run Chr(34) & GetRootPath() & "\Source\build_project.vbs" & Chr(34)
            Case "4"
                shell.Run Chr(34) & GetRootPath() & "\Source\run_project.vbs" & Chr(34)
            Case "5"
                ' Build then run
                shell.Run Chr(34) & GetRootPath() & "\Source\build_project.vbs" & Chr(34)
                WScript.Sleep 2000
                shell.Run Chr(34) & GetRootPath() & "\Source\run_project.vbs" & Chr(34)
            Case "6"
                shell.Run Chr(34) & GetRootPath() & "\Source\setup_ide.vbs" & Chr(34)
            Case "7"
                ShowHelp
            Case "8"
                Exit Do
            Case Else
                MsgBox "Invalid selection!", vbExclamation
        End Select
    Loop
End Sub

Sub ShowHelp()
    Dim helpText
    helpText = "SimpleGBA-IDE Help" & vbCrLf & _
               "==================" & vbCrLf & vbCrLf & _
               "1. CREATE PROJECT: Creates new GBA project with:" & vbCrLf & _
               "   - build.bat (compilation script)" & vbCrLf & _
               "   - Makefile (build configuration)" & vbCrLf & _
               "   - source/main.c (starter code)" & vbCrLf & _
               "   - include/gba.h (GBA headers)" & vbCrLf & vbCrLf & _
               "2. OPEN PROJECT: Opens project in editor" & vbCrLf & vbCrLf & _
               "3. BUILD PROJECT: Compiles project using build.bat" & vbCrLf & vbCrLf & _
               "4. RUN IN EMULATOR: Runs compiled ROM in mGBA" & vbCrLf & vbCrLf & _
               "Requirements:" & vbCrLf & _
               "- DevkitPro installed (C:\devkitPro)" & vbCrLf & _
               "- mGBA emulator (for testing)" & vbCrLf & vbCrLf & _
               "Project structure:" & vbCrLf & _
               "SimpleGBA-IDE/" & vbCrLf & _
               "├── SimpleGBA-IDE.exe" & vbCrLf & _
               "├── config.ini" & vbCrLf & _
               "├── Projects/" & vbCrLf & _
               "└── Source/" & vbCrLf & _
               "    └── *.vbs scripts" & vbCrLf & vbCrLf & _
               "First time setup:" & vbCrLf & _
               "1. Run setup_ide.vbs or launch SimpleGBA-IDE.exe" & vbCrLf & _
               "2. Set paths to your tools" & vbCrLf & _
               "3. Create your first project!"
    
    MsgBox helpText, vbInformation, "Help"
End Sub