#!/usr/bin/env bash
# ==============================================================================
# Script: 6_restore_all.sh
# Purpose: Re-enable all disabled packages back to factory default state.
# ==============================================================================

set -euo pipefail

DEVICE="${1:-$(adb devices | grep -v "List" | grep "device" | head -n 1 | awk '{print $1}')}"

if [[ -z "$DEVICE" ]]; then
    echo "Error: No connected ADB device detected."
    exit 1
fi

PACKAGES_TO_RESTORE=(
    "com.amazon.bueller.photos"
    "com.amazon.bueller.music"
    "com.amazon.recess"
    "com.amazon.ods.kindleconnect"
    "com.amazon.ceviche"
    "com.amazon.ftv.screensaver"
    "com.amazon.hybridadidservice"
    "com.amazon.tv.acr"
    "com.amazon.dp.logger"
)

echo "--- Re-enabling All Packages ---"
for pkg in "${PACKAGES_TO_RESTORE[@]}"; do
    echo -n "Enabling $pkg: "
    adb -s "$DEVICE" shell pm enable "$pkg" 2>&1 || true
done

echo -e "\n--- Currently Disabled Packages ---"
adb -s "$DEVICE" shell pm list packages -d
echo "Restoration complete."
