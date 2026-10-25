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
    "com.amazon.gamehub"
    "com.amazon.shoptv.client"
    "com.amazon.shoptv.firetv.client"
    "com.amazon.tv.livetv"
    "com.amazon.hybridadidservice"
    "com.amazon.tv.acr"
    "com.amazon.dp.logger"
    "com.amazon.firetv.troubleshooting"
)

echo "--- 1. Re-enabling All Packages ---"
for pkg in "${PACKAGES_TO_RESTORE[@]}"; do
    echo -n "Enabling $pkg: "
    adb -s "$DEVICE" shell pm enable "$pkg" 2>&1 || true
done

echo -e "\n--- 2. Resetting AppOps Restrictions ---"
STREAMING_APPS=(
    "in.startv.hotstar"
    "com.netflix.ninja"
    "tv.airtel.xstream.tvapp"
    "com.suntv.sunnxt"
    "ahaflix.tv"
    "com.crunchyroll.crunchyroid"
    "com.amazon.device.crashmanager"
    "com.stremio.one"
    "com.sportzx.live"
    "dev.app.cloosi"
    "uk.co.uktv.dave"
    "org.videolan.vlc"
    "org.xbmc.kodi"
    "com.disney.disneyplus"
    "uk.co.bbc.iplayer"
    "com.channel4.ondemand"
    "air.ITVMobilePlayer"
)
for app in "${STREAMING_APPS[@]}"; do
    adb -s "$DEVICE" shell cmd appops set "$app" RUN_IN_BACKGROUND default 2>/dev/null || \
    adb -s "$DEVICE" shell appops set "$app" RUN_IN_BACKGROUND default 2>/dev/null || true
done
echo "Reset AppOps background execution to default."

echo -e "\n--- 3. Restoring Default Autoplay & Process Limits ---"
adb -s "$DEVICE" shell settings put global auto_play_video 1 || true
adb -s "$DEVICE" shell settings put global auto_play_audio 1 || true
adb -s "$DEVICE" shell settings delete global standard_background_process_limit || true

echo -e "\n--- 4. Currently Disabled Packages ---"
adb -s "$DEVICE" shell pm list packages -d
echo "Restoration complete."
