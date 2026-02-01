' Setup tool paths
Option Explicit

Function GetRootPath()
    Dim fso
    Set fso = CreateObject("Scripting.FileSystemObject")
    GetRootPath = fso.GetParentFolderName(fso.GetParentFolderName(WScript.ScriptFullName))
End Function

Function GetConfigPath()
    GetConfigPath = GetRootPath() & "\config.ini"
End Function

Dim fso, shell, configFile, choice
Set fso = CreateObject("Scripting.FileSystemObject")
Set shell = CreateObject("WScript.Shell")

' Create configuration file
Sub CreateConfig()
    Dim configPath, config, defaultEditor, mgbaPath, devkitPath
    
    configPath = GetConfigPath()
    
    ' Ask for paths
    devkitPath = InputBox("Path to DevkitPro (e.g.: C:\devkitPro):", "IDE Setup", "C:\devkitPro")
    If devkitPath = "" Then devkitPath = "C:\devkitPro"
    
    mgbaPath = InputBox("Path to mGBA (e.g.: C:\Program Files\mGBA\mGBA.exe):", "IDE Setup", "C:\Program Files\mGBA\mGBA.exe")
    If mgbaPath = "" Then mgbaPath = "C:\Program Files\mGBA\mGBA.exe"
    
    defaultEditor = InputBox("Path to text editor (e.g.: notepad.exe):", "IDE Setup", "notepad.exe")
    If defaultEditor = "" Then defaultEditor = "notepad.exe"
    
    Set config = fso.CreateTextFile(configPath, True)
    
    config.WriteLine "[Paths]"
    config.WriteLine "; Path to DevkitPro compiler"
    config.WriteLine "DEVKITPRO=" & devkitPath
    config.WriteLine ""
    config.WriteLine "; Path to mGBA emulator"
    config.WriteLine "MGBA=" & mgbaPath
    config.WriteLine ""
    config.WriteLine "; Default text editor"
    config.WriteLine "EDITOR=" & defaultEditor
    config.WriteLine ""
    config.WriteLine "; Projects folder (relative to IDE root)"
    config.WriteLine "PROJECTS_PATH=Projects"
    config.WriteLine ""
    config.WriteLine "[Settings]"
    config.WriteLine "AUTO_RUN=true"
    config.WriteLine "SHOW_CONSOLE=true"
    
    config.Close
    
    ' Create projects folder
    Dim projectsPath
    projectsPath = GetRootPath() & "\Projects"
    If Not fso.FolderExists(projectsPath) Then
        fso.CreateFolder projectsPath
        MsgBox "Created Projects folder: " & projectsPath, vbInformation
    End If
    
    MsgBox "Configuration saved!" & vbCrLf & _
           "Projects folder: " & projectsPath & vbCrLf & _
           "Config file: " & configPath, vbInformation, "SimpleGBA-IDE"
End Sub

' Setup main menu
choice = InputBox( _
    "=== IDE SETUP === " & vbCrLf & _
    "1. Create/update configuration" & vbCrLf & _
    "2. Check DevkitPro installation" & vbCrLf & _
    "3. Check mGBA installation" & vbCrLf & _
    "4. Test project creation" & vbCrLf & _
    "5. Exit" & vbCrLf & vbCrLf & _
    "Select action:", _
    "IDE Setup", "1")

Select Case choice
    Case "1"
        CreateConfig
    Case "2"
        shell.Run "cmd /k echo Testing DevkitPro... && make --version", 1, True
    Case "3"
        Dim mgbaTest
        On Error Resume Next
        Set mgbaTest = fso.OpenTextFile(GetConfigPath(), 1)
        Do While Not mgbaTest.AtEndOfStream
            Dim line
            line = mgbaTest.ReadLine
            If Left(line, 5) = "MGBA=" Then
                mgbaPath = Mid(line, 6)
                If fso.FileExists(mgbaPath) Then
                    MsgBox "mGBA found at: " & mgbaPath, vbInformation
                Else
                    MsgBox "mGBA NOT found at: " & mgbaPath, vbExclamation
                End If
                Exit Do
            End If
        Loop
        mgbaTest.Close
        On Error GoTo 0
    Case "4"
        shell.Run Chr(34) & GetRootPath() & "\Source\create_project.vbs" & Chr(34)
    Case "5"
        ' Exit
End Select