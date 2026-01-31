' SimpleGBA-IDE Project Creator
Option Explicit

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
    
    ' Get template choice
    templateChoice = InputBox( _
        "Select template:" & vbCrLf & _
        "1. Minimal project (Mode 3 bitmap)" & vbCrLf & _
        "2. Platformer template" & vbCrLf & _
        "3. RPG template", _
        "Select Template", "1")
    
    If templateChoice = "" Then
        templateChoice = "1"
    End If
    
    ' Create project
    CreateProject projectName, templateChoice
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

Sub CreateProject(name, template)
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
    
    ' Create project files
    CreateBuildBat projectPath, name
    CreateMakefile projectPath, name
    CreateCompileBat projectPath, name
    CreateMainC projectPath, name
    CreateGbaHeader projectPath
    CreateReadme projectPath, name
    
    ' Create shortcut
    CreateShortcut projectPath, name
    
    MsgBox "Project '" & name & "' created successfully!" & vbCrLf & _
           "Location: " & projectPath & vbCrLf & vbCrLf & _
           "To build: Open project folder and double-click build.bat", vbInformation
End Sub

Function GetProjectsPath()
    Dim configPath, path, line, file
    ' Default path
    path = fso.GetParentFolderName(WScript.ScriptFullName) & "\Projects"
    
    ' Try to read from config
    configPath = fso.GetParentFolderName(WScript.ScriptFullName) & "\config.ini"
    
    If fso.FileExists(configPath) Then
        Set file = fso.OpenTextFile(configPath, 1)
        Do While Not file.AtEndOfStream
            line = Trim(file.ReadLine)
            If Left(line, 13) = "PROJECTS_PATH=" Then
                path = Mid(line, 14)
                Exit Do
            End If
        Loop
        file.Close
    End If
    
    ' Create folder if needed
    If Not fso.FolderExists(path) Then
        fso.CreateFolder path
    End If
    
    GetProjectsPath = path
End Function

Sub CreateBuildBat(path, name)
    Dim file
    Set file = fso.CreateTextFile(path & "\build.bat", True)
    
    file.WriteLine "@echo off"
    file.WriteLine "title Building " & name
    file.WriteLine "echo ========================================"
    file.WriteLine "echo."
    file.WriteLine "set DEVKITPRO=C:\devkitPro"
    file.WriteLine "set DEVKITARM=%DEVKITPRO%\devkitARM"
    file.WriteLine ""
    file.WriteLine "if not exist ""%DEVKITARM%\bin\arm-eabi-gcc.exe"" ("
    file.WriteLine "    echo ERROR: Compiler not found!"
    file.WriteLine "    pause"
    file.WriteLine "    exit /b 1"
    file.WriteLine ")"
    file.WriteLine ""
    file.WriteLine "echo Compiler found:"
    file.WriteLine """%DEVKITARM%\bin\arm-eabi-gcc.exe"" --version"
    file.WriteLine "echo."
    file.WriteLine ""
    file.WriteLine "echo Building project..."
    file.WriteLine "set PATH=%DEVKITARM%\bin;%PATH%"
    file.WriteLine "C:\devkitPro\msys\bin\make.exe"
    file.WriteLine ""
    file.WriteLine "if errorlevel 1 ("
    file.WriteLine "    echo."
    file.WriteLine "    echo BUILD FAILED"
    file.WriteLine "    pause"
    file.WriteLine "    exit /b 1"
    file.WriteLine ")"
    file.WriteLine ""
    file.WriteLine "if exist " & name & ".gba ("
    file.WriteLine "    echo."
    file.WriteLine "    echo SUCCESS: " & name & ".gba created!"
    file.WriteLine "    for %%F in (" & name & ".gba) do set /a size=%%~zF/1024"
    file.WriteLine "    echo Size: !size! KB"
    file.WriteLine ") else ("
    file.WriteLine "    echo."
    file.WriteLine "    echo ERROR: ROM file not created"
    file.WriteLine ")"
    file.WriteLine ""
    file.WriteLine "echo."
    file.WriteLine "pause"
    
    file.Close
End Sub

Sub CreateMakefile(path, name)
    Dim file
    Set file = fso.CreateTextFile(path & "\Makefile", True)
    
    file.WriteLine "# GBA Makefile"
    file.WriteLine "TARGET := " & name
    file.WriteLine "SOURCES := source"
    file.WriteLine "INCLUDES := include"
    file.WriteLine ""
    file.WriteLine "# Tools"
    file.WriteLine "CC := C:/devkitPro/devkitARM/bin/arm-eabi-gcc.exe"
    file.WriteLine "OBJCOPY := C:/devkitPro/devkitARM/bin/arm-eabi-objcopy.exe"
    file.WriteLine ""
    file.WriteLine "# Flags"
    file.WriteLine "CFLAGS := -mthumb -mthumb-interwork -O2 -Wall -std=c99 -I$(INCLUDES)"
    file.WriteLine "LDFLAGS := -mthumb -mthumb-interwork -specs=gba.specs"
    file.WriteLine ""
    file.WriteLine "# Files"
    file.WriteLine "CFILES := $(SOURCES)/main.c"
    file.WriteLine "OBJFILES := main.o"
    file.WriteLine ""
    file.WriteLine "# Rules"
    file.WriteLine "all: $(TARGET).gba"
    file.WriteLine ""
    file.WriteLine "$(TARGET).gba: $(TARGET).elf"
    file.WriteLine "	$(OBJCOPY) -O binary $< $@"
    file.WriteLine "	@echo ROM created: $(TARGET).gba"
    file.WriteLine ""
    file.WriteLine "$(TARGET).elf: $(OBJFILES)"
    file.WriteLine "	$(CC) $(LDFLAGS) -o $@ $^"
    file.WriteLine ""
    file.WriteLine "main.o: $(SOURCES)/main.c"
    file.WriteLine "	$(CC) $(CFLAGS) -c $< -o $@"
    file.WriteLine ""
    file.WriteLine "clean:"
    file.WriteLine "	rm -f *.o *.elf *.gba"
    file.WriteLine ""
    file.WriteLine ".PHONY: all clean"
    
    file.Close
End Sub

Sub CreateCompileBat(path, name)
    Dim file
    Set file = fso.CreateTextFile(path & "\compile.bat", True)
    
    file.WriteLine "@echo off"
    file.WriteLine "echo Alternative compilation for " & name
    file.WriteLine "echo."
    file.WriteLine ""
    file.WriteLine "set CC=C:\devkitPro\devkitARM\bin\arm-eabi-gcc.exe"
    file.WriteLine "set OBJCOPY=C:\devkitPro\devkitARM\bin\arm-eabi-objcopy.exe"
    file.WriteLine ""
    file.WriteLine "echo Compiling..."
    file.WriteLine "%CC% -mthumb -mthumb-interwork -O2 -Wall -c source\main.c -o main.o -Iinclude"
    file.WriteLine ""
    file.WriteLine "if errorlevel 1 ("
    file.WriteLine "    echo Compilation failed!"
    file.WriteLine "    pause"
    file.WriteLine "    exit /b 1"
    file.WriteLine ")"
    file.WriteLine ""
    file.WriteLine "echo Linking..."
    file.WriteLine "%CC% -mthumb -mthumb-interwork -specs=gba.specs main.o -o " & name & ".elf"
    file.WriteLine ""
    file.WriteLine "echo Creating ROM..."
    file.WriteLine "%OBJCOPY% -O binary " & name & ".elf " & name & ".gba"
    file.WriteLine ""
    file.WriteLine "del main.o " & name & ".elf 2>nul"
    file.WriteLine ""
    file.WriteLine "if exist " & name & ".gba ("
    file.WriteLine "    echo Success! ROM created."
    file.WriteLine ") else ("
    file.WriteLine "    echo Failed to create ROM."
    file.WriteLine ")"
    file.WriteLine ""
    file.WriteLine "pause"
    
    file.Close
End Sub

Sub CreateMainC(path, name)
    Dim file
    Set file = fso.CreateTextFile(path & "\source\main.c", True)
    
    file.WriteLine "/* " & name & " - GBA Game */"
    file.WriteLine "#include ""gba.h"""
    file.WriteLine ""
    file.WriteLine "int main() {"
    file.WriteLine "    // Set video mode 3 (bitmap) with BG2"
    file.WriteLine "    REG_DISPCNT = MODE_3 | BG2_ENABLE;"
    file.WriteLine "    "
    file.WriteLine "    // Video memory pointer"
    file.WriteLine "    u16* vram = (u16*)MEM_VRAM;"
    file.WriteLine "    "
    file.WriteLine "    // Fill screen with red"
    file.WriteLine "    for(int i = 0; i < SCREEN_WIDTH * SCREEN_HEIGHT; i++) {"
    file.WriteLine "        vram[i] = RGB15(31, 0, 0);"
    file.WriteLine "    }"
    file.WriteLine "    delay(1000000);"
    file.WriteLine "    "
    file.WriteLine "    // Fill screen with green"
    file.WriteLine "    for(int i = 0; i < SCREEN_WIDTH * SCREEN_HEIGHT; i++) {"
    file.WriteLine "        vram[i] = RGB15(0, 31, 0);"
    file.WriteLine "    }"
    file.WriteLine "    delay(1000000);"
    file.WriteLine "    "
    file.WriteLine "    // Fill screen with blue"
    file.WriteLine "    for(int i = 0; i < SCREEN_WIDTH * SCREEN_HEIGHT; i++) {"
    file.WriteLine "        vram[i] = RGB15(0, 0, 31);"
    file.WriteLine "    }"
    file.WriteLine "    "
    file.WriteLine "    // Main game loop"
    file.WriteLine "    while(1) {"
    file.WriteLine "        u16 keys = keysDown();"
    file.WriteLine "        "
    file.WriteLine "        if(keys & KEY_A) {"
    file.WriteLine "            for(int i = 0; i < SCREEN_WIDTH * SCREEN_HEIGHT; i++) {"
    file.WriteLine "                vram[i] = RGB15(31, 31, 0);  // Yellow"
    file.WriteLine "            }"
    file.WriteLine "        }"
    file.WriteLine "        "
    file.WriteLine "        if(keys & KEY_B) {"
    file.WriteLine "            for(int i = 0; i < SCREEN_WIDTH * SCREEN_HEIGHT; i++) {"
    file.WriteLine "                vram[i] = RGB15(31, 0, 31);  // Purple"
    file.WriteLine "            }"
    file.WriteLine "        }"
    file.WriteLine "        "
    file.WriteLine "        delay(10000);"
    file.WriteLine "    }"
    file.WriteLine "    "
    file.WriteLine "    return 0;"
    file.WriteLine "}"
    
    file.Close
End Sub

Sub CreateGbaHeader(path)
    Dim file
    Set file = fso.CreateTextFile(path & "\include\gba.h", True)
    
    file.WriteLine "#ifndef GBA_H"
    file.WriteLine "#define GBA_H"
    file.WriteLine ""
    file.WriteLine "// Basic types"
    file.WriteLine "typedef unsigned char   u8;"
    file.WriteLine "typedef unsigned short  u16;"
    file.WriteLine "typedef unsigned int    u32;"
    file.WriteLine ""
    file.WriteLine "// Video modes"
    file.WriteLine "#define MODE_0          0x0000"
    file.WriteLine "#define MODE_1          0x0001"
    file.WriteLine "#define MODE_2          0x0002"
    file.WriteLine "#define MODE_3          0x0003"
    file.WriteLine "#define MODE_4          0x0004"
    file.WriteLine "#define MODE_5          0x0005"
    file.WriteLine ""
    file.WriteLine "// Background flags"
    file.WriteLine "#define BG0_ENABLE      0x0100"
    file.WriteLine "#define BG1_ENABLE      0x0200"
    file.WriteLine "#define BG2_ENABLE      0x0400"
    file.WriteLine "#define BG3_ENABLE      0x0800"
    file.WriteLine "#define OBJ_ENABLE      0x1000"
    file.WriteLine ""
    file.WriteLine "// Memory addresses"
    file.WriteLine "#define MEM_VRAM        0x06000000"
    file.WriteLine "#define MEM_OAM         0x07000000"
    file.WriteLine "#define MEM_PAL         0x05000000"
    file.WriteLine ""
    file.WriteLine "// Registers"
    file.WriteLine "#define REG_DISPCNT     *(volatile u32*)0x04000000"
    file.WriteLine "#define REG_KEYINPUT    *(volatile u16*)0x04000130"
    file.WriteLine ""
    file.WriteLine "// Screen size"
    file.WriteLine "#define SCREEN_WIDTH    240"
    file.WriteLine "#define SCREEN_HEIGHT   160"
    file.WriteLine ""
    file.WriteLine "// Colors (RGB5: 5 bits per component)"
    file.WriteLine "#define RGB15(r,g,b)    ((r) | ((g) << 5) | ((b) << 10))"
    file.WriteLine ""
    file.WriteLine "// Keys"
    file.WriteLine "#define KEY_A           0x0001"
    file.WriteLine "#define KEY_B           0x0002"
    file.WriteLine "#define KEY_SELECT      0x0004"
    file.WriteLine "#define KEY_START       0x0008"
    file.WriteLine "#define KEY_RIGHT       0x0010"
    file.WriteLine "#define KEY_LEFT        0x0020"
    file.WriteLine "#define KEY_UP          0x0040"
    file.WriteLine "#define KEY_DOWN        0x0080"
    file.WriteLine "#define KEY_R           0x0100"
    file.WriteLine "#define KEY_L           0x0200"
    file.WriteLine ""
    file.WriteLine "// Delay function"
    file.WriteLine "static inline void delay(int count) {"
    file.WriteLine "    for(volatile int i = 0; i < count; i++);"
    file.WriteLine "}"
    file.WriteLine ""
    file.WriteLine "// Key functions"
    file.WriteLine "static inline u16 keysDown() { "
    file.WriteLine "    return ~REG_KEYINPUT & 0x03FF; "
    file.WriteLine "}"
    file.WriteLine ""
    file.WriteLine "static inline u16 keysHeld() { "
    file.WriteLine "    return ~REG_KEYINPUT & 0x03FF; "
    file.WriteLine "}"
    file.WriteLine ""
    file.WriteLine "#endif // GBA_H"
    
    file.Close
End Sub

Sub CreateReadme(path, name)
    Dim file
    Set file = fso.CreateTextFile(path & "\README.txt", True)
    
    file.WriteLine "GBA PROJECT: " & UCase(name)
    file.WriteLine "============================="
    file.WriteLine ""
    file.WriteLine "Created with SimpleGBA-IDE"
    file.WriteLine ""
    file.WriteLine "QUICK START:"
    file.WriteLine "1. Double-click build.bat to compile"
    file.WriteLine "2. Open " & name & ".gba in mGBA emulator"
    file.WriteLine ""
    file.WriteLine "FILES:"
    file.WriteLine "- build.bat      - Main build script"
    file.WriteLine "- compile.bat    - Alternative build script"
    file.WriteLine "- Makefile       - Build configuration"
    file.WriteLine "- source/main.c  - Source code"
    file.WriteLine "- include/gba.h  - GBA header"
    file.WriteLine ""
    file.WriteLine "CONTROLS:"
    file.WriteLine "- A button: Change to yellow"
    file.WriteLine "- B button: Change to purple"
    file.WriteLine ""
    file.WriteLine "DEVELOPMENT:"
    file.WriteLine "1. Edit source/main.c to change game logic"
    file.WriteLine "2. Add graphics to graphics/ folder"
    file.WriteLine "3. Add sounds to sound/ folder"
    file.WriteLine ""
    file.WriteLine "REQUIREMENTS:"
    file.WriteLine "- DevkitPro installed at C:\devkitPro"
    file.WriteLine "- mGBA emulator for testing"
    
    file.Close
End Sub

Sub CreateShortcut(path, name)
    Dim shortcut
    Set shortcut = shell.CreateShortcut(path & "\" & name & ".lnk")
    shortcut.TargetPath = "explorer.exe"
    shortcut.Arguments = Chr(34) & path & Chr(34)
    shortcut.WorkingDirectory = path
    shortcut.Description = "Open " & name & " project folder"
    shortcut.IconLocation = "shell32.dll,4"
    shortcut.Save
End Sub