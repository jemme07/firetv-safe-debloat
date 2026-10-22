@echo off
setlocal enabledelayedexpansion
title Fire TV Safe Debloat - verify_health

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
    echo Or run: verify_health.bat ^<FIRETV_IP^>:5555
    echo.
    pause
    exit /b 1
)

echo ========================================================
echo  Fire TV Safe Debloat - System Health Verification
echo  Device: %DEVICE%
echo ========================================================
echo.

echo 1. Device ^& OS Info:
for /f "tokens=*" %%v in ('adb -s %DEVICE% shell getprop ro.product.model 2^>nul') do echo Model: %%v
for /f "tokens=*" %%v in ('adb -s %DEVICE% shell getprop ro.build.version.name 2^>nul') do echo Fire OS / Build: %%v
for /f "tokens=*" %%v in ('adb -s %DEVICE% shell getprop ro.build.version.sdk 2^>nul') do echo Android SDK: %%v

echo.
echo 2. Active Launcher Activity:
adb -s %DEVICE% shell "pm resolve-activity -a android.intent.action.MAIN -c android.intent.category.HOME" 2>nul | findstr /i "packageName= ActivityInfo:"

echo.
echo 3. Available Storage (/data):
adb -s %DEVICE% shell df -h /data

echo.
echo 4. RAM ^& ZRAM Memory:
adb -s %DEVICE% shell dumpsys meminfo | findstr /i "Total Free Used ZRAM"

echo.
echo 5. Active Private DNS:
adb -s %DEVICE% shell settings get global private_dns_mode
adb -s %DEVICE% shell settings get global private_dns_specifier

echo.
echo 6. Match Content Frame Rate:
adb -s %DEVICE% shell settings get global match_content_frame_rate

echo.
echo 7. Currently Disabled Packages:
adb -s %DEVICE% shell pm list packages -d

echo.
echo [DONE] Health verification complete.
echo.
pause
