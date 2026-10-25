#!/usr/bin/env bash
# ==============================================================================
# Script: disable_batch.sh
# Purpose: Safely disable candidate bloatware & telemetry packages for user 0.
# Method: adb shell pm disable-user --user 0 <pkg>
# ==============================================================================

set -euo pipefail

DEVICE="${1:-$(adb devices | grep -v "List" | grep "device" | head -n 1 | awk '{print $1}')}"

if [[ -z "$DEVICE" ]]; then
    echo "Error: No connected ADB device detected. Specify device IP:port as \$1."
    exit 1
fi

echo "Target device: $DEVICE"

# Confirmed safe candidate packages to disable
CANDIDATE_PACKAGES=(
    # Consumer background sync services & media
    "com.amazon.bueller.photos"      # Amazon Photos background sync
    "com.amazon.bueller.music"       # Amazon Music TV app
    "com.amazon.recess"              # Casual gaming promo hub
    "com.amazon.ods.kindleconnect"   # Remote screen sharing support stub
    "com.amazon.gamehub"             # Amazon Game Hub promo
    "com.amazon.ceviche"             # Live TV promotional aggregator
    "com.amazon.ftv.screensaver"     # Promo screensaver prefetcher
    "com.amazon.shoptv.client"       # Shop on TV client
    "com.amazon.shoptv.firetv.client" # Shop on Fire TV client
    "com.amazon.tv.livetv"           # Live TV aggregator
    "com.amazon.firetv.troubleshooting" # Fire TV troubleshooting promo app
    # Telemetry and ad profiling
    "com.amazon.hybridadidservice"   # Amazon Advertising ID service
    "com.amazon.dp.logger"           # Device platform telemetry logger
)

echo "--- Disabling Approved Packages in Controlled Batches ---"
for pkg in "${CANDIDATE_PACKAGES[@]}"; do
    echo -n "Disabling $pkg: "
    adb -s "$DEVICE" shell pm disable-user --user 0 "$pkg" 2>&1 || true
    sleep 0.5
done

echo -e "\n--- Verifying Launcher & System State ---"
adb -s "$DEVICE" get-state
adb -s "$DEVICE" shell "cmd package resolve-activity -a android.intent.action.MAIN -c android.intent.category.HOME" | grep -E "packageName=|ActivityInfo:"

echo -e "\n--- Currently Disabled Packages ---"
adb -s "$DEVICE" shell pm list packages -d

echo "Batch execution complete."
