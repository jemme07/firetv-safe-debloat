#!/system/bin/sh
# Fire TV Remote Partner Buttons Remapper -> Projectivy Launcher
# Intercepts Netflix, Disney+, and Amazon Music remote buttons and redirects to Projectivy.

TARGET="com.spocky.projengmenu/.ui.home.MainActivity"

while true; do
  # Wait for a fresh button event (using -T 1 so it never loops on historical logs)
  logcat -T 1 -m 1 -e "launchApp for application (netflix|disney|amazonmusic)" >/dev/null 2>&1
  # Bring Projectivy forward immediately using SINGLE_TOP flag (0x30000000) so it doesn't reset position if already open
  am start -f 0x30000000 "$TARGET" >/dev/null 2>&1
  # Settle and suppress any background Appstore or Amazon Music launch
  sleep 0.15
  am force-stop com.amazon.bueller.music >/dev/null 2>&1
  am force-stop com.amazon.venezia >/dev/null 2>&1
  am start -f 0x30000000 "$TARGET" >/dev/null 2>&1
  sleep 1
done
