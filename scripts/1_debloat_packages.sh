#!/usr/bin/env bash
# ==============================================================================
# Script: 1_debloat_packages.sh
# Purpose: Safely disable non-essential Fire OS bloatware packages for user 0.
# Method: adb shell pm disable-user --user 0 <pkg>
# ==============================================================================

set -euo pipefail

# Auto-detect ADB device if not specified
DEVICE="${1:-$(adb devices | grep -v "List" | grep "device" | head -n 1 | awk '{print $1}')}"

if [[ -z "$DEVICE" ]]; then
    echo "Error: No connected ADB device detected. Specify device IP:port as \$1."
    exit 1
fi

echo "Connecting to device: $DEVICE"

# Confirmed safe standalone consumer extras & promo packages
DEBLOAT_PACKAGES=(
    # Consumer background sync services
    "com.amazon.bueller.photos"      # Amazon Photos background sync
    "com.amazon.bueller.music"       # Amazon Music TV app
    "com.amazon.recess"              # Casual gaming promo hub
    "com.amazon.ods.kindleconnect"   # Remote screen sharing support stub
    "com.amazon.ceviche"             # Live TV guide aggregator
    "com.amazon.ftv.screensaver"     # Promo screensaver prefetcher
)

echo "--- Disabling Safe Bloatware Packages ---"
for pkg in "${DEBLOAT_PACKAGES[@]}"; do
    echo -n "Disabling $pkg: "
    adb -s "$DEVICE" shell pm disable-user --user 0 "$pkg" 2>&1 || true
done

echo -e "\n--- Verifying Launcher & Connection ---"
adb -s "$DEVICE" get-state
adb -s "$DEVICE" shell "pm resolve-activity -a android.intent.action.MAIN -c android.intent.category.HOME" | grep "packageName="

echo "Debloat script complete."
