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

echo "1. Device & OS Info:"
MODEL="$( (adb -s "$DEVICE" shell getprop ro.product.model 2>/dev/null || true) | tr -d '\r\n')"
FIREOS_VER="$( (adb -s "$DEVICE" shell getprop ro.build.version.name 2>/dev/null || true) | tr -d '\r\n')"
SDK_VER="$( (adb -s "$DEVICE" shell getprop ro.build.version.sdk 2>/dev/null || true) | tr -d '\r\n')"
echo "Model: ${MODEL:-Unknown}"
echo "Fire OS / Build: ${FIREOS_VER:-Unknown}"
echo "Android SDK: ${SDK_VER:-Unknown}"

echo -e "\n2. Active Launcher Activity:"
(adb -s "$DEVICE" shell "pm resolve-activity -a android.intent.action.MAIN -c android.intent.category.HOME" 2>/dev/null || true) | grep -E "packageName=|ActivityInfo:" || echo "Default launcher active"

echo -e "\n3. Available Storage (/data):"
adb -s "$DEVICE" shell df -h /data 2>/dev/null || echo "Storage info unavailable"

echo -e "\n4. RAM & ZRAM Memory:"
(adb -s "$DEVICE" shell dumpsys meminfo 2>/dev/null || true) | grep -E "Total RAM:|Free RAM:|Used RAM:|ZRAM:" || echo "Memory info unavailable"

echo -e "\n5. Active Private DNS:"
echo "Mode: $(adb -s "$DEVICE" shell settings get global private_dns_mode 2>/dev/null || echo 'N/A')"
echo "Host: $(adb -s "$DEVICE" shell settings get global private_dns_specifier 2>/dev/null || echo 'N/A')"

echo -e "\n6. Match Content Frame Rate:"
echo "Value: $(adb -s "$DEVICE" shell settings get global match_content_frame_rate 2>/dev/null || echo 'N/A')"

echo -e "\n7. Disabled Packages Count:"
DISABLED_COUNT="$( (adb -s "$DEVICE" shell pm list packages -d 2>/dev/null || true) | grep -c "package:" 2>/dev/null || true)"
echo "${DISABLED_COUNT:-0} package(s) disabled."
echo "Check finished."
