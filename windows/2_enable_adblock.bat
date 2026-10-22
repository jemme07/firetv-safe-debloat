@echo off
setlocal enabledelayedexpansion
title Fire TV Safe Debloat - 2_enable_adblock

set "DEVICE=%~1"
set "DNS_HOST=%~2"
if "%DNS_HOST%"=="" set "DNS_HOST=dns.adguard.com"

:: Auto-detect device if not provided
if not defined DEVICE (
    for /f "skip=1 tokens=1" %%d in ('adb devices 2^>nul') do (
        if not "%%d"=="" if not defined DEVICE set "DEVICE=%%d"
    )
)

if not defined DEVICE (
    echo [ERROR] No connected ADB device detected.
    echo Please connect your Fire TV first: adb connect ^<IP^>:5555
    echo Or run: 2_enable_adblock.bat ^<FIRETV_IP^>:5555 [DNS_HOST]
    echo.
    pause
    exit /b 1
)

echo ========================================================
echo  Fire TV Safe Debloat - Enable Ad-Block ^& Privacy
echo  Device: %DEVICE%
echo  DNS Provider: %DNS_HOST%
echo ========================================================
echo.

echo --- 1. Disabling Ad-Tracking ^& ACR Telemetry ---
set AD_PACKAGES=com.amazon.hybridadidservice com.amazon.tv.acr com.amazon.dp.logger

for %%p in (%AD_PACKAGES%) do (
    <nul set /p "=Disabling %%p: "
    adb -s %DEVICE% shell pm disable-user --user 0 %%p 2>nul
    if !errorlevel! equ 0 (
        echo [OK]
    ) else (
        echo [SKIPPED/UNAVAILABLE]
    )
)

echo.
echo --- 2. Setting Strict Privacy Toggles ---
adb -s %DEVICE% shell settings put secure limit_ad_tracking 1
adb -s %DEVICE% shell settings put secure interest_based_ads 0
adb -s %DEVICE% shell settings put global usage_metrics_marketing_enabled 0
echo Privacy flags set.

echo.
echo --- 3. Configuring Encrypted Private DNS (%DNS_HOST%) ---
set "SDK_VER=0"
for /f "tokens=*" %%v in ('adb -s %DEVICE% shell getprop ro.build.version.sdk 2^>nul') do set "SDK_VER=%%v"

if %SDK_VER% geq 28 (
    adb -s %DEVICE% shell settings put global private_dns_mode hostname
    adb -s %DEVICE% shell settings put global private_dns_specifier %DNS_HOST%
    echo Private DNS Mode:
    adb -s %DEVICE% shell settings get global private_dns_mode
    echo Private DNS Host:
    adb -s %DEVICE% shell settings get global private_dns_specifier
    echo [OK] Private DNS activated.
) else (
    echo [NOTICE] Android SDK level is %SDK_VER% (Fire OS 5 or 6).
    echo Native Android Private DNS requires Android 9+ (Fire OS 7+).
    echo Privacy toggles and telemetry package disables were applied successfully.
    echo For Fire OS 5/6, configure AdGuard DNS (94.140.14.14) on your Wi-Fi router.
)

echo.
echo [DONE] Ad-blocking configuration complete.
echo.
pause
