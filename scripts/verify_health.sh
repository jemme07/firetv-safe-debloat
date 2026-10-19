#!/usr/bin/env bash
# ==============================================================================
# Script: verify_health.sh
# Purpose: Health check report for Fire TV Stick.
# ==============================================================================

set -euo pipefail

DEVICE="${1:-$(adb devices | grep -v "List" | grep "device" | head -n 1 | awk '{print $1}')}"

if [[ -z "$DEVICE" ]]; then
    echo "Error: No connected ADB device detected."
    exit 1
fi

echo "=========================================="
echo " Fire TV Health Check ($DEVICE)"
echo "=========================================="

echo "1. Device State:"
adb -s "$DEVICE" get-state

echo -e "\n2. Active Launcher Activity:"
adb -s "$DEVICE" shell "pm resolve-activity -a android.intent.action.MAIN -c android.intent.category.HOME" | grep -E "packageName=|ActivityInfo:"

echo -e "\n3. Available Storage (/data):"
adb -s "$DEVICE" shell df -h /data

echo -e "\n4. RAM & ZRAM Memory:"
adb -s "$DEVICE" shell dumpsys meminfo | grep -E "Total RAM:|Free RAM:|Used RAM:|ZRAM:"

echo -e "\n5. Active Private DNS:"
echo "Mode: $(adb -s "$DEVICE" shell settings get global private_dns_mode)"
echo "Host: $(adb -s "$DEVICE" shell settings get global private_dns_specifier)"

echo -e "\n6. Match Content Frame Rate:"
echo "Value: $(adb -s "$DEVICE" shell settings get global match_content_frame_rate)"

echo -e "\n7. Disabled Packages Count:"
adb -s "$DEVICE" shell pm list packages -d | wc -l
echo "Check finished."
