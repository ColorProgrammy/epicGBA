' SimpleGBA-IDE Main Menu
Option Explicit

Dim fso, shell
Set fso = CreateObject("Scripting.FileSystemObject")
Set shell = CreateObject("WScript.Shell")

' Check for config
If Not fso.FileExists("config.ini") Then
    MsgBox "Configuration not found. Run setup_ide.vbs first.", vbExclamation
    shell.Run "setup_ide.vbs"
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
                shell.Run "create_project.vbs"
            Case "2"
                shell.Run "open_project.vbs"
            Case "3"
                shell.Run "build_project.vbs"
            Case "4"
                shell.Run "run_project.vbs"
            Case "5"
                ' Build then run
                shell.Run "build_project.vbs"
                WScript.Sleep 2000
                shell.Run "run_project.vbs"
            Case "6"
                shell.Run "setup_ide.vbs"
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
               "First time setup:" & vbCrLf & _
               "1. Run setup_ide.vbs" & vbCrLf & _
               "2. Set paths to your tools" & vbCrLf & _
               "3. Create your first project!"
    
    MsgBox helpText, vbInformation, "Help"
End Sub
