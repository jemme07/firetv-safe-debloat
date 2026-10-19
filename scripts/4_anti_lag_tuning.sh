#!/usr/bin/env bash
# ==============================================================================
# Script: 4_anti_lag_tuning.sh
# Purpose: Stop background memory hogs, disable video autoplay, and cap processes.
# ==============================================================================

set -euo pipefail

DEVICE="${1:-$(adb devices | grep -v "List" | grep "device" | head -n 1 | awk '{print $1}')}"

if [[ -z "$DEVICE" ]]; then
    echo "Error: No connected ADB device detected."
    exit 1
fi

echo "--- 1. Capping Background Process Limits ---"
adb -s "$DEVICE" shell settings put global standard_background_process_limit 2
echo "Background Process Limit: $(adb -s "$DEVICE" shell settings get global standard_background_process_limit)"

echo -e "\n--- 2. Disabling Home Screen Video & Audio Autoplay ---"
adb -s "$DEVICE" shell settings put global auto_play_video 0
adb -s "$DEVICE" shell settings put global auto_play_audio 0
echo "Autoplay Video: $(adb -s "$DEVICE" shell settings get global auto_play_video)"
echo "Autoplay Audio: $(adb -s "$DEVICE" shell settings get global auto_play_audio)"

echo -e "\n--- 3. AppOps Background Lockdown on Heavy Streaming Apps ---"
# Prevents apps from running background listeners or hogging RAM when closed
STREAMING_APPS=(
    "in.startv.hotstar"
    "com.netflix.ninja"
    "tv.airtel.xstream.tvapp"
    "com.suntv.sunnxt"
    "ahaflix.tv"
    "com.crunchyroll.crunchyroid"
    "com.amazon.device.crashmanager"
)

for app in "${STREAMING_APPS[@]}"; do
    if adb -s "$DEVICE" shell pm list packages | grep -q "$app"; then
        echo -n "Locking background activity for $app: "
        adb -s "$DEVICE" shell cmd appops set "$app" RUN_IN_BACKGROUND ignore
        echo "Locked"
    fi
done

echo -e "\n--- 4. Purging App Cache Junk ---"
adb -s "$DEVICE" shell pm trim-caches 2G || true

echo "Anti-lag tuning applied successfully!"
