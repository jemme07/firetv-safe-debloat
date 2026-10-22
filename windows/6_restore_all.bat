@echo off
setlocal enabledelayedexpansion
title Fire TV Safe Debloat - 6_restore_all

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
    echo Or run: 6_restore_all.bat ^<FIRETV_IP^>:5555
    echo.
    pause
    exit /b 1
)

echo ========================================================
echo  Fire TV Safe Debloat - Restore All Factory Defaults
echo  Device: %DEVICE%
echo ========================================================
echo.

echo --- 1. Re-enabling All Packages ---
set PACKAGES=com.amazon.bueller.photos com.amazon.bueller.music com.amazon.recess com.amazon.ods.kindleconnect com.amazon.ceviche com.amazon.ftv.screensaver com.amazon.hybridadidservice com.amazon.tv.acr com.amazon.dp.logger

for %%p in (%PACKAGES%) do (
    <nul set /p "=Enabling %%p: "
    adb -s %DEVICE% shell pm enable %%p 2>nul
    if !errorlevel! equ 0 (
        echo [OK]
    ) else (
        echo [SKIPPED/UNAVAILABLE]
    )
)

echo.
echo --- 2. Resetting AppOps Restrictions ---
set STREAMING_APPS=in.startv.hotstar com.netflix.ninja tv.airtel.xstream.tvapp com.suntv.sunnxt ahaflix.tv com.crunchyroll.crunchyroid com.amazon.device.crashmanager

for %%a in (%STREAMING_APPS%) do (
    adb -s %DEVICE% shell cmd appops set %%a RUN_IN_BACKGROUND default 2>nul || adb -s %DEVICE% shell appops set %%a RUN_IN_BACKGROUND default 2>nul
)
echo AppOps background permissions restored.

echo.
echo --- 3. Restoring Autoplay ^& Process Limit Settings ---
adb -s %DEVICE% shell settings put global auto_play_video 1
adb -s %DEVICE% shell settings put global auto_play_audio 1
adb -s %DEVICE% shell settings delete global standard_background_process_limit 2>nul
echo Settings restored.

echo.
echo --- 4. Currently Disabled Packages ---
adb -s %DEVICE% shell pm list packages -d

echo.
echo [DONE] Full restore completed.
echo.
pause
