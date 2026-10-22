@echo off
setlocal enabledelayedexpansion
title Fire TV Safe Debloat - 4_anti_lag_tuning

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
    echo Or run: 4_anti_lag_tuning.bat ^<FIRETV_IP^>:5555
    echo.
    pause
    exit /b 1
)

echo ========================================================
echo  Fire TV Safe Debloat - Anti-Lag ^& Memory Optimization
echo  Device: %DEVICE%
echo ========================================================
echo.

echo --- 1. Capping Background Process Limits ---
adb -s %DEVICE% shell settings put global standard_background_process_limit 2
echo Background Process Limit:
adb -s %DEVICE% shell settings get global standard_background_process_limit
echo [NOTE] Android OS resets background process limit back to default on reboot.

echo.
echo --- 2. Disabling Home Screen Video ^& Audio Autoplay ---
adb -s %DEVICE% shell settings put global auto_play_video 0
adb -s %DEVICE% shell settings put global auto_play_audio 0
echo Autoplay Video:
adb -s %DEVICE% shell settings get global auto_play_video
echo Autoplay Audio:
adb -s %DEVICE% shell settings get global auto_play_audio

echo.
echo --- 3. AppOps Background Lockdown on Heavy Streaming Apps ---
set STREAMING_APPS=in.startv.hotstar com.netflix.ninja tv.airtel.xstream.tvapp com.suntv.sunnxt ahaflix.tv com.crunchyroll.crunchyroid com.amazon.device.crashmanager

for %%a in (%STREAMING_APPS%) do (
    adb -s %DEVICE% shell pm list packages | findstr /i "%%a" >nul
    if !errorlevel! equ 0 (
        <nul set /p "=Locking background activity for %%a: "
        adb -s %DEVICE% shell cmd appops set %%a RUN_IN_BACKGROUND ignore 2>nul || adb -s %DEVICE% shell appops set %%a RUN_IN_BACKGROUND ignore 2>nul
        echo [LOCKED]
    )
)

echo.
echo --- 4. Purging App Cache Junk ---
adb -s %DEVICE% shell pm trim-caches 2G 2>nul
echo Cache trim requested.

echo.
echo [DONE] Anti-lag tuning applied successfully.
echo.
pause
