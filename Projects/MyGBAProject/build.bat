@echo off
title Building MyGBAProject3
echo ========================================
echo.
set DEVKITPRO=C:\devkitPro
set DEVKITARM=%DEVKITPRO%\devkitARM

if not exist "%DEVKITARM%\bin\arm-eabi-gcc.exe" (
    echo ERROR: Compiler not found!
    pause
    exit /b 1
)

echo Compiler found:
"%DEVKITARM%\bin\arm-eabi-gcc.exe" --version
echo.

echo Building project...
set PATH=%DEVKITARM%\bin;%PATH%
C:\devkitPro\msys\bin\make.exe

if errorlevel 1 (
    echo.
    echo BUILD FAILED
    pause
    exit /b 1
)

if exist MyGBAProject3.gba (
    echo.
    echo SUCCESS: MyGBAProject3.gba created!
    for %%F in (MyGBAProject3.gba) do set /a size=%%~zF/1024
    echo Size: !size! KB
) else (
    echo.
    echo ERROR: ROM file not created
)

echo.
pause
