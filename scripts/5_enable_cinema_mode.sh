#!/usr/bin/env bash
# ==============================================================================
# Script: 5_enable_cinema_mode.sh
# Purpose: Enable 24 fps Match Original Frame Rate for cinema playback without judder.
# ==============================================================================

set -euo pipefail

DEVICE="${1:-$(adb devices | grep -v "List" | grep "device" | head -n 1 | awk '{print $1}')}"

if [[ -z "$DEVICE" ]]; then
    echo "Error: No connected ADB device detected."
    exit 1
fi

echo "Enabling Match Original Frame Rate..."
adb -s "$DEVICE" shell settings put global match_content_frame_rate 1
echo "match_content_frame_rate: $(adb -s "$DEVICE" shell settings get global match_content_frame_rate)"
echo "Cinema 24p mode active."
