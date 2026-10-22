@echo off
setlocal enabledelayedexpansion
title Fire TV Safe Debloat - 5_enable_cinema_mode

set "DEVICE=%~1"

:: Auto-detect device if not provided
if not defined DEVICE (
    for /f "skip=1 tokens=1" %%d in ('adb devices 2^>nul') do (
        if not "%%d"=="" if not defined DEVICE set "DEVICE=%%d"
    )
)

if not defined DEVICE (
    echo [ERROR] No connected ADB device detected.
    echo Please connect your Fire TV first: adb connect ^<IP^>:5555
    echo Or run: 5_enable_cinema_mode.bat ^<FIRETV_IP^>:5555
    echo.
    pause
    exit /b 1
)

echo ========================================================
echo  Fire TV Safe Debloat - Enable Match Content Frame Rate
echo  Device: %DEVICE%
echo ========================================================
echo.

adb -s %DEVICE% shell settings put global match_content_frame_rate 1
echo match_content_frame_rate:
adb -s %DEVICE% shell settings get global match_content_frame_rate

echo.
echo [DONE] Cinema 24 fps frame rate matching active.
echo.
pause
