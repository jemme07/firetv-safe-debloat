#!/usr/bin/env bash
# ==============================================================================
# Script: 3_disable_adblock.sh
# Purpose: Revert ad-blocking and restore default Fire OS DNS settings.
# ==============================================================================

set -euo pipefail

DEVICE="${1:-$(adb devices | grep -v "List" | grep "device" | head -n 1 | awk '{print $1}')}"

if [[ -z "$DEVICE" ]]; then
    echo "Error: No connected ADB device detected."
    exit 1
fi

echo "--- 1. Re-enabling Ad & ACR Packages ---"
AD_PACKAGES=(
    "com.amazon.hybridadidservice"
    "com.amazon.tv.acr"
    "com.amazon.dp.logger"
)

for pkg in "${AD_PACKAGES[@]}"; do
    echo -n "Enabling $pkg: "
    adb -s "$DEVICE" shell pm enable "$pkg" 2>&1 || true
done

echo -e "\n--- 2. Resetting Privacy Toggles ---"
adb -s "$DEVICE" shell settings put secure limit_ad_tracking 0 || true
adb -s "$DEVICE" shell settings put secure interest_based_ads 1 || true
adb -s "$DEVICE" shell settings put global usage_metrics_marketing_enabled 1 || true

echo -e "\n--- 3. Resetting Private DNS to Automatic ---"
adb -s "$DEVICE" shell settings put global private_dns_mode opportunistic || true
adb -s "$DEVICE" shell settings delete global private_dns_specifier 2>/dev/null || true

echo "Ad-blocking reverted. DNS set back to automatic."
