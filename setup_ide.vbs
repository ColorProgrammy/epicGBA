' Setup tool paths
Option Explicit

Dim fso, shell, configFile, choice
Set fso = CreateObject("Scripting.FileSystemObject")
Set shell = CreateObject("WScript.Shell")

' Create configuration file
Sub CreateConfig()
    Dim configPath, config
    configPath = "config.ini"
    
    Set config = fso.CreateTextFile(configPath, True)
    
    config.WriteLine "[Paths]"
    config.WriteLine "; Path to DevkitPro compiler"
    config.WriteLine "DEVKITPRO=" & InputBox("Path to DevkitPro (e.g.: C:\devkitPro):", "IDE Setup")
    
    config.WriteLine "; Path to mGBA emulator"
    config.WriteLine "MGBA=" & InputBox("Path to mGBA (e.g.: C:\Program Files\mGBA\mGBA.exe):", "IDE Setup")
    
    config.WriteLine "; Default text editor"
    config.WriteLine "EDITOR=" & InputBox("Path to text editor (e.g.: C:\Program Files\Notepad++\notepad++.exe):", "IDE Setup")
    
    config.WriteLine "; Default projects path"
    config.WriteLine "PROJECTS_PATH=" & fso.GetParentFolderName(WScript.ScriptFullName) & "\Projects"
    
    config.WriteLine "[Settings]"
    config.WriteLine "AUTO_RUN=true"
    config.WriteLine "SHOW_CONSOLE=true"
    
    config.Close
    
    ' Create projects folder
    Dim projectsPath
    projectsPath = fso.GetParentFolderName(WScript.ScriptFullName) & "\Projects"
    If Not fso.FolderExists(projectsPath) Then
        fso.CreateFolder projectsPath
    End If
    
    MsgBox "Configuration saved!", vbInformation, "SimpleGBA-IDE"
End Sub

' Setup main menu
choice = InputBox( _
    "=== IDE SETUP === " & vbCrLf & _
    "1. Create/update configuration" & vbCrLf & _
    "2. Check DevkitPro installation" & vbCrLf & _
    "3. Create project templates" & vbCrLf & _
    "4. Exit" & vbCrLf & vbCrLf & _
    "Select action:", _
    "IDE Setup", "1")

Select Case choice
    Case "1"
        CreateConfig
    Case "2"
        shell.Run "cmd /k make --version", 1, True
    Case "3"
        CreateTemplates
    Case "4"
        ' Exit
End Select

Sub CreateTemplates()
    ' Create templates folder
    Dim templatesPath
    templatesPath = fso.GetParentFolderName(WScript.ScriptFullName) & "\templates"
    If Not fso.FolderExists(templatesPath) Then
        fso.CreateFolder templatesPath
    End If
    
    ' Minimal project template
    CreateMinimalTemplate templatesPath & "\minimal"
    
    MsgBox "Templates created!", vbInformation
End Sub

Sub CreateMinimalTemplate(templatePath)
    If Not fso.FolderExists(templatePath) Then
        fso.CreateFolder templatePath
    End If
    
    ' Create Makefile
    Dim makefile
    Set makefile = fso.CreateTextFile(templatePath & "\Makefile", True)
    
    makefile.WriteLine "# Minimal GBA Makefile"
    makefile.WriteLine "TARGET := $(shell basename $(CURDIR))"
    makefile.WriteLine "BUILD := build"
    makefile.WriteLine "SOURCES := source"
    makefile.WriteLine "INCLUDES := include"
    makefile.WriteLine ""
    makefile.WriteLine "# Add source files here"
    makefile.WriteLine "CFILES := $(wildcard $(SOURCES)/*.c)"
    makefile.WriteLine ""
    makefile.WriteLine "# Use DevkitARM"
    makefile.WriteLine "include $(DEVKITARM)/gba_rules"
    makefile.WriteLine ""
    makefile.WriteLine ".PHONY: all clean"
    makefile.WriteLine ""
    makefile.WriteLine "all: $(TARGET).gba"
    makefile.WriteLine ""
    makefile.WriteLine "%.gba: %.elf"
    makefile.WriteLine "	@echo building ... $(notdir $@)"
    makefile.WriteLine "	@$(OBJCOPY) -O binary $< $@"
    makefile.WriteLine ""
    makefile.WriteLine "clean:"
    makefile.WriteLine "	@echo cleaning ..."
    makefile.WriteLine "	@rm -rf $(BUILD) $(TARGET).elf $(TARGET).gba"
    
    makefile.Close
    
    ' Create folder structure
    fso.CreateFolder templatePath & "\source"
    fso.CreateFolder templatePath & "\include"
    fso.CreateFolder templatePath & "\graphics"
    fso.CreateFolder templatePath & "\sound"
    
    ' Create main file
    Dim mainFile
    Set mainFile = fso.CreateTextFile(templatePath & "\source\main.c", True)
    
    mainFile.WriteLine "/* Minimal GBA Game */"
    mainFile.WriteLine "#include <tonc.h>"
    mainFile.WriteLine ""
    mainFile.WriteLine "int main() {"
    mainFile.WriteLine "    // Set video mode 3 (16-bit bitmap)"
    mainFile.WriteLine "    REG_DISPCNT = MODE_3 | BG2_ON;"
    mainFile.WriteLine ""
    mainFile.WriteLine "    // Fill screen with red color"
    mainFile.WriteLine "    for(int i = 0; i < SCREEN_WIDTH * SCREEN_HEIGHT; i++) {"
    mainFile.WriteLine "        vid_mem[i] = RGB15(31, 0, 0);"
    mainFile.WriteLine "    }"
    mainFile.WriteLine ""
    mainFile.WriteLine "    // Main game loop"
    mainFile.WriteLine "    while(1) {"
    mainFile.WriteLine "        // Input handling"
    mainFile.WriteLine "        key_poll();"
    mainFile.WriteLine ""
    mainFile.WriteLine "        // A button - green screen"
    mainFile.WriteLine "        if(key_hit(KEY_A)) {"
    mainFile.WriteLine "            for(int i = 0; i < SCREEN_WIDTH * SCREEN_HEIGHT; i++) {"
    mainFile.WriteLine "                vid_mem[i] = RGB15(0, 31, 0);"
    mainFile.WriteLine "            }"
    mainFile.WriteLine "        }"
    mainFile.WriteLine ""
    mainFile.WriteLine "        // B button - blue screen"
    mainFile.WriteLine "        if(key_hit(KEY_B)) {"
    mainFile.WriteLine "            for(int i = 0; i < SCREEN_WIDTH * SCREEN_HEIGHT; i++) {"
    mainFile.WriteLine "                vid_mem[i] = RGB15(0, 0, 31);"
    mainFile.WriteLine "            }"
    mainFile.WriteLine "        }"
    mainFile.WriteLine "    }"
    mainFile.WriteLine ""
    mainFile.WriteLine "    return 0;"
    mainFile.WriteLine "}"
    
    mainFile.Close
End Sub