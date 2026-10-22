@echo off
setlocal enabledelayedexpansion
title Fire TV Safe Debloat - 1_debloat_packages

set "DEVICE="
set "KEEP_PHOTOS=0"

:: Parse arguments
:parse_args
if "%~1"=="" goto after_args
if /i "%~1"=="--keep-photos" (
    set "KEEP_PHOTOS=1"
) else if /i "%~1"=="-keep-photos" (
    set "KEEP_PHOTOS=1"
) else if not defined DEVICE (
    set "DEVICE=%~1"
)
shift
goto parse_args
:after_args

:: Auto-detect device if not provided
if not defined DEVICE (
    for /f "skip=1 tokens=1" %%d in ('adb devices 2^>nul') do (
        if not "%%d"=="" if not defined DEVICE set "DEVICE=%%d"
    )
)

if not defined DEVICE (
    echo [ERROR] No connected ADB device detected.
    echo Please connect your Fire TV first: adb connect ^<IP^>:5555
    echo Or run: 1_debloat_packages.bat ^<FIRETV_IP^>:5555
    echo.
    pause
    exit /b 1
)

echo ========================================================
echo  Fire TV Safe Debloat - Disabling Bloatware Packages
echo  Device: %DEVICE%
echo ========================================================
echo.

if "%KEEP_PHOTOS%"=="1" (
    echo [INFO] Option --keep-photos detected: Amazon Photos will remain enabled.
)

set PACKAGES=com.amazon.bueller.music com.amazon.recess com.amazon.ods.kindleconnect com.amazon.ceviche com.amazon.ftv.screensaver
if not "%KEEP_PHOTOS%"=="1" (
    set PACKAGES=%PACKAGES% com.amazon.bueller.photos
)

for %%p in (%PACKAGES%) do (
    <nul set /p "=Disabling %%p: "
    adb -s %DEVICE% shell pm disable-user --user 0 %%p 2>nul
    if !errorlevel! equ 0 (
        echo [OK]
    ) else (
        echo [SKIPPED/UNAVAILABLE]
    )
)

echo.
echo --- Verifying Launcher ---
adb -s %DEVICE% shell "pm resolve-activity -a android.intent.action.MAIN -c android.intent.category.HOME" | findstr "packageName="
echo.
echo [DONE] Safe debloat completed successfully.
echo.
pause
