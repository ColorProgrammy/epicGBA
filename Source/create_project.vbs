' SimpleGBA-IDE Project Creator
Option Explicit

Function GetRootPath()
    Dim fso
    Set fso = CreateObject("Scripting.FileSystemObject")
    GetRootPath = fso.GetParentFolderName(fso.GetParentFolderName(WScript.ScriptFullName))
End Function

Function GetProjectsPath()
    Dim configPath, path, line, file, fso
    Set fso = CreateObject("Scripting.FileSystemObject")
    
    ' По умолчанию - папка Projects в корне
    path = GetRootPath() & "\Projects"
    
    ' Пробуем прочитать из конфига
    configPath = GetRootPath() & "\config.ini"
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
        If Err.Number <> 0 Then
            MsgBox "Cannot create Projects folder: " & path & vbCrLf & "Error: " & Err.Description, vbExclamation
            WScript.Quit
        End If
        On Error GoTo 0
    End If
    
    GetProjectsPath = path
End Function

Dim fso, shell, choice, projectName, templateChoice, projectPath, projectsPath
Set fso = CreateObject("Scripting.FileSystemObject")
Set shell = CreateObject("WScript.Shell")

' Main function
Main

Sub Main()
    ' Get project name
    projectName = InputBox("Enter project name:", "Create GBA Project", "MyGBAProject")
    If projectName = "" Then
        MsgBox "Project name cannot be empty!", vbExclamation
        Exit Sub
    End If
    
    ' Clean project name
    projectName = CleanFileName(projectName)
    
    ' Create project
    CreateProject projectName
End Sub

Function CleanFileName(name)
    ' Remove invalid characters from filename
    Dim invalidChars, i
    invalidChars = Array("\", "/", ":", "*", "?", """", "<", ">", "|")
    
    For i = 0 To UBound(invalidChars)
        name = Replace(name, invalidChars(i), "")
    Next
    
    CleanFileName = name
End Function

Sub CreateProject(name)
    ' Determine projects path
    projectsPath = GetProjectsPath()
    projectPath = projectsPath & "\" & name
    
    ' Check if project exists
    If fso.FolderExists(projectPath) Then
        If MsgBox("Project '" & name & "' already exists. Overwrite?", vbYesNo + vbQuestion) = vbNo Then
            Exit Sub
        End If
    End If
    
    ' Create folder structure
    On Error Resume Next
    If fso.FolderExists(projectPath) Then
        fso.DeleteFolder projectPath, True
    End If
    
    fso.CreateFolder projectPath
    fso.CreateFolder projectPath & "\source"
    fso.CreateFolder projectPath & "\include"
    fso.CreateFolder projectPath & "\graphics"
    fso.CreateFolder projectPath & "\sound"
    
    If Err.Number <> 0 Then
        MsgBox "Error creating project structure: " & Err.Description, vbExclamation
        Exit Sub
    End If
    On Error GoTo 0
    
    ' Create project files
    CreateBuildBat projectPath, name
    CreateMakefile projectPath, name
    CreateCompileBat projectPath, name
    CreateMainC projectPath, name
    CreateGbaHeader projectPath
    CreateReadme projectPath, name
    
    MsgBox "Project '" & name & "' created successfully!" & vbCrLf & _
           "Location: " & projectPath & vbCrLf & vbCrLf & _
           "To build: Open project folder and double-click build.bat", vbInformation
End Sub

' ... (остальные функции CreateBuildBat, CreateMakefile и т.д. остаются такими же как в предыдущем коде)
' Копируйте их из предыдущей версии