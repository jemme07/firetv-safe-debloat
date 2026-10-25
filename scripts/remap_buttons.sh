#!/system/bin/sh
# Fire TV Remote Partner Buttons Remapper -> Projectivy Launcher
# Intercepts Netflix, Disney+, and Amazon Music remote buttons and redirects to Projectivy.

TARGET="com.spocky.projengmenu/.ui.home.MainActivity"

logcat -c
while true; do
  logcat -m 1 -e "launchApp for application (netflix|disney|amazonmusic)" >/dev/null 2>&1
  am start -W -f 0x10000000 "$TARGET" >/dev/null 2>&1
done
