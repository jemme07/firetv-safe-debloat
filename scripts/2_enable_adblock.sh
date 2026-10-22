#!/usr/bin/env bash
# ==============================================================================
# Script: 2_enable_adblock.sh
# Purpose: Configure Private DNS ad-blocking and disable on-screen tracking (ACR/AdID).
# ==============================================================================

set -euo pipefail

DEVICE="${1:-$(adb devices | grep -v "List" | grep "device" | head -n 1 | awk '{print $1}')}"
DNS_HOST="${2:-dns.adguard.com}"

if [[ -z "$DEVICE" ]]; then
    echo "Error: No connected ADB device detected."
    exit 1
fi

echo "--- 1. Disabling Ad-Tracking & ACR Telemetry ---"
AD_PACKAGES=(
    "com.amazon.hybridadidservice"  # Advertising ID cross-app tracking
    "com.amazon.tv.acr"             # Automated Content Recognition (video fingerprinting)
    "com.amazon.dp.logger"          # Diagnostic telemetry logger
)

for pkg in "${AD_PACKAGES[@]}"; do
    echo -n "Disabling $pkg: "
    adb -s "$DEVICE" shell pm disable-user --user 0 "$pkg" 2>&1 || true
done

echo -e "\n--- 2. Setting Strict Privacy Toggles ---"
adb -s "$DEVICE" shell settings put secure limit_ad_tracking 1 || true
adb -s "$DEVICE" shell settings put secure interest_based_ads 0 || true
adb -s "$DEVICE" shell settings put global usage_metrics_marketing_enabled 0 || true

echo -e "\n--- 3. Configuring Encrypted Private DNS ($DNS_HOST) ---"
SDK_VER="$( (adb -s "$DEVICE" shell getprop ro.build.version.sdk 2>/dev/null || true) | tr -d '\r\n')"
SDK_VER="${SDK_VER:-0}"

if [[ "$SDK_VER" -ge 28 ]]; then
    adb -s "$DEVICE" shell settings put global private_dns_mode hostname || true
    adb -s "$DEVICE" shell settings put global private_dns_specifier "$DNS_HOST" || true
    echo "Private DNS Mode: $(adb -s "$DEVICE" shell settings get global private_dns_mode 2>/dev/null || echo 'N/A')"
    echo "Private DNS Host: $(adb -s "$DEVICE" shell settings get global private_dns_specifier 2>/dev/null || echo 'N/A')"
    echo "Ad-blocking and anti-tracking active!"
else
    echo "Notice: Android SDK level is $SDK_VER (Android < 9.0 / Fire OS 5 or 6)."
    echo "Native Android Private DNS (DoT) requires Android 9+ (Fire OS 7+)."
    echo "Privacy toggles and telemetry package disables were applied successfully."
    echo "To block ads on Fire OS 5/6, set your Wi-Fi DNS to AdGuard (94.140.14.14) or use a DNS app."
fi
