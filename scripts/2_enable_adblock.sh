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
adb -s "$DEVICE" shell settings put secure limit_ad_tracking 1
adb -s "$DEVICE shell settings put secure interest_based_ads 0"
adb -s "$DEVICE" shell settings put global usage_metrics_marketing_enabled 0

echo -e "\n--- 3. Activating Encrypted Private DNS ($DNS_HOST) ---"
adb -s "$DEVICE" shell settings put global private_dns_mode hostname
adb -s "$DEVICE" shell settings put global private_dns_specifier "$DNS_HOST"

echo "Private DNS Mode: $(adb -s "$DEVICE" shell settings get global private_dns_mode)"
echo "Private DNS Host: $(adb -s "$DEVICE" shell settings get global private_dns_specifier)"
echo "Ad-blocking and anti-tracking active!"
