@echo off
setlocal enabledelayedexpansion
title Fire TV Safe Debloat - 3_disable_adblock

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
    echo Or run: 3_disable_adblock.bat ^<FIRETV_IP^>:5555
    echo.
    pause
    exit /b 1
)

echo ========================================================
echo  Fire TV Safe Debloat - Revert Ad-Block ^& Reset DNS
echo  Device: %DEVICE%
echo ========================================================
echo.

echo --- 1. Re-enabling Ad ^& ACR Packages ---
set AD_PACKAGES=com.amazon.hybridadidservice com.amazon.tv.acr com.amazon.dp.logger

for %%p in (%AD_PACKAGES%) do (
    <nul set /p "=Enabling %%p: "
    adb -s %DEVICE% shell pm enable %%p 2>nul
    if !errorlevel! equ 0 (
        echo [OK]
    ) else (
        echo [SKIPPED/UNAVAILABLE]
    )
)

echo.
echo --- 2. Resetting Privacy Toggles to Default ---
adb -s %DEVICE% shell settings put secure limit_ad_tracking 0
adb -s %DEVICE% shell settings put secure interest_based_ads 1
adb -s %DEVICE% shell settings put global usage_metrics_marketing_enabled 1
echo Privacy flags restored.

echo.
echo --- 3. Resetting Private DNS to Automatic ---
adb -s %DEVICE% shell settings put global private_dns_mode opportunistic
adb -s %DEVICE% shell settings delete global private_dns_specifier 2>nul
echo DNS restored to automatic.

echo.
echo [DONE] Ad-blocking reverted successfully.
echo.
pause
