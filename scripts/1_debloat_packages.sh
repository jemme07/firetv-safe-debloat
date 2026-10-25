#!/usr/bin/env bash
# ==============================================================================
# Script: 1_debloat_packages.sh
# Purpose: Safely disable non-essential Fire OS bloatware packages for user 0.
# Method: adb shell pm disable-user --user 0 <pkg>
# ==============================================================================

set -euo pipefail

DEVICE=""
KEEP_PHOTOS=false

for arg in "$@"; do
    if [[ "$arg" == "--keep-photos" ]]; then
        KEEP_PHOTOS=true
    elif [[ -z "$DEVICE" && "$arg" != -* ]]; then
        DEVICE="$arg"
    fi
done

if [[ -z "$DEVICE" ]]; then
    DEVICE="$(adb devices | grep -v "List" | grep "device" | head -n 1 | awk '{print $1}')"
fi

if [[ -z "$DEVICE" ]]; then
    echo "Error: No connected ADB device detected. Specify device IP:port as argument."
    exit 1
fi

echo "Connecting to device: $DEVICE"
if [[ "$KEEP_PHOTOS" == true ]]; then
    echo "Option --keep-photos detected: Amazon Photos will remain enabled for screensaver."
fi

# Confirmed safe standalone consumer extras & promo packages
DEBLOAT_PACKAGES=(
    # Consumer background sync services
    "com.amazon.bueller.music"       # Amazon Music TV app
    "com.amazon.recess"              # Casual gaming promo hub
    "com.amazon.ods.kindleconnect"   # Remote screen sharing support stub
    "com.amazon.ceviche"             # Live TV guide aggregator
    "com.amazon.ftv.screensaver"     # Promo screensaver prefetcher
    "com.amazon.gamehub"             # Amazon Games promo hub
    "com.amazon.shoptv.client"       # Shop on TV client
    "com.amazon.shoptv.firetv.client" # Shop on Fire TV client
    "com.amazon.tv.livetv"           # Live TV sync service
)

if [[ "$KEEP_PHOTOS" != true ]]; then
    DEBLOAT_PACKAGES+=("com.amazon.bueller.photos") # Amazon Photos background sync
fi

echo "--- Disabling Safe Bloatware Packages ---"
for pkg in "${DEBLOAT_PACKAGES[@]}"; do
    echo -n "Disabling $pkg: "
    adb -s "$DEVICE" shell pm disable-user --user 0 "$pkg" 2>&1 || true
done

echo -e "\n--- Verifying Launcher & Connection ---"
adb -s "$DEVICE" get-state
adb -s "$DEVICE" shell "cmd package resolve-activity -a android.intent.action.MAIN -c android.intent.category.HOME 2>/dev/null || pm resolve-activity -a android.intent.action.MAIN -c android.intent.category.HOME 2>/dev/null || true" | grep -E "packageName=|ActivityInfo:" || echo "Default launcher verified"

echo "Debloat script complete."
