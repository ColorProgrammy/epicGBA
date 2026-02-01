@echo off
echo Building and playing MyGBAProject3
echo.

set CC=C:\devkitPro\devkitARM\bin\arm-eabi-gcc.exe
set OBJCOPY=C:\devkitPro\devkitARM\bin\arm-eabi-objcopy.exe

echo Compiling...
%CC% -mthumb -mthumb-interwork -O2 -Wall -std=c99 -c source\main.c -o main.o -Iinclude

if errorlevel 1 (
    echo Compilation failed!
    pause
    exit /b 1
)

echo Linking...
%CC% -mthumb -mthumb-interwork -specs=gba.specs main.o -o MyGBAProject3.elf

echo Creating ROM...
%OBJCOPY% -O binary MyGBAProject3.elf MyGBAProject3.gba

del main.o MyGBAProject3.elf 2>nul

if exist MyGBAProject3.gba (
    echo Success! ROM created.
    echo.
    echo Looking for mGBA emulator...
    
    if exist "C:\Program Files\mGBA\mGBA.exe" (
        echo Launching mGBA...
        "C:\Program Files\mGBA\mGBA.exe" MyGBAProject3.gba
    ) else if exist "C:\Program Files (x86)\mGBA\mGBA.exe" (
        echo Launching mGBA...
        "C:\Program Files (x86)\mGBA\mGBA.exe" MyGBAProject3.gba
    ) else (
        echo mGBA emulator not found in default locations.
        echo Please install mGBA or update the path in play.bat
        pause
    )
) else (
    echo Failed to create ROM.
)

pause
