# Manual ADB Commands & DIY Optimization Guide

For users who prefer to run ADB commands manually, inspect each command individually, or pick and choose specific optimizations rather than executing automated scripts.

All commands can be pasted directly into **Terminal (macOS/Linux)**, **PowerShell (Windows)**, or **Command Prompt (Windows)**.

---

## Table of Contents

1. [Step 0: Connect to Fire TV over Wi-Fi](#step-0-connect-to-fire-tv-over-wi-fi)
2. [Optimization 1: Safe Package Debloating](#optimization-1-safe-package-debloating)
3. [Optimization 2: Network Ad-Blocking & Anti-Tracking](#optimization-2-network-ad-blocking--anti-tracking)
4. [Optimization 3: Anti-Lag & Background RAM Lockdown](#optimization-3-anti-lag--background-ram-lockdown)
5. [Optimization 4: 24 fps Cinema Frame Rate Matching](#optimization-4-24-fps-cinema-frame-rate-matching)
6. [System Verification & Diagnostics](#system-verification--diagnostics)
7. [Rollback & Reversal Commands](#rollback--reversal-commands)
8. [Technical Deep Dive & FAQ](#technical-deep-dive--faq)

---

## Step 0: Connect to Fire TV over Wi-Fi

1. On your Fire TV, enable Developer Options:
   - Go to **Settings > My Fire TV > About**.
   - Highlight the device name and press the **Select button 7 times**.
2. Enable ADB:
   - Go to **Settings > My Fire TV > Developer Options**.
   - Turn **ADB Debugging** to **ON**.
3. Note your device IP address in **Settings > My Fire TV > About > Network**.
4. In your computer terminal or CMD, connect:
   ```bash
   adb connect <FIRETV_IP>:5555
   ```
5. Look at your TV screen and check **"Always allow from this computer"** -> select **OK**.

---

## Optimization 1: Safe Package Debloating

Disables standalone promo hubs, prefetchers, and background sync services for user 0 without touching system partitions or root.

> [!TIP]
> **Using Amazon Photos for screensaver / ambient display?**
> If you want your TV to cycle through personal photos on the screensaver (e.g. on Panasonic, Insignia, or Omni TVs), **do not run** the command for `com.amazon.bueller.photos`.

### Copy-Paste Commands:

```bash
# Amazon Music TV app background service
adb shell pm disable-user --user 0 com.amazon.bueller.music

# Recess casual gaming hub & trials
adb shell pm disable-user --user 0 com.amazon.recess

# Remote screen sharing diagnostics stub
adb shell pm disable-user --user 0 com.amazon.ods.kindleconnect

# Live TV guide & channel aggregator
adb shell pm disable-user --user 0 com.amazon.ceviche

# Promotional screensaver prefetcher
adb shell pm disable-user --user 0 com.amazon.ftv.screensaver

# (OPTIONAL) Amazon Photos sync - Skip if you use photo screensavers
adb shell pm disable-user --user 0 com.amazon.bueller.photos
```

### Verify Disabled Packages:
```bash
adb shell pm list packages -d
```

---

## Optimization 2: Network Ad-Blocking & Anti-Tracking

Disables on-screen telemetry, cross-app ad tracking, and routes DNS queries through an encrypted Private DNS provider (DNS-over-TLS).

> [!NOTE]
> **Fire OS Version Requirement for Private DNS**:
> Native Private DNS (`private_dns_mode`) is supported on **Fire OS 7+ (Android 9+)** and **Fire OS 8 (Android 11)**.
> For older **Fire OS 5 / 6** devices (Fire TV Stick 2nd Gen), configure AdGuard DNS (`94.140.14.14`) directly in your Wi-Fi router or TV Wi-Fi IP settings.

### 1. Disable Tracking Packages & Telemetry:
```bash
# Advertising ID cross-app tracking service
adb shell pm disable-user --user 0 com.amazon.hybridadidservice

# Automated Content Recognition (video fingerprinting telemetry)
adb shell pm disable-user --user 0 com.amazon.tv.acr

# Diagnostic telemetry logger
adb shell pm disable-user --user 0 com.amazon.dp.logger
```

### 2. Set Privacy Toggles:
```bash
adb shell settings put secure limit_ad_tracking 1
adb shell settings put secure interest_based_ads 0
adb shell settings put global usage_metrics_marketing_enabled 0
```

### 3. Configure Encrypted Private DNS:

Choose your preferred DNS provider:

- **AdGuard DNS** (Default - blocks ads, trackers, and malicious domains):
  ```bash
  adb shell settings put global private_dns_mode hostname
  adb shell settings put global private_dns_specifier dns.adguard.com
  ```

- **NextDNS** (Custom blocklists; replace `<YOUR_ID>` with your NextDNS ID):
  ```bash
  adb shell settings put global private_dns_mode hostname
  adb shell settings put global private_dns_specifier <YOUR_ID>.dns.nextdns.io
  ```

- **Mullvad DNS** (Ad-blocking & privacy):
  ```bash
  adb shell settings put global private_dns_mode hostname
  adb shell settings put global private_dns_specifier adblock.doh.mullvad.net
  ```

### Verify DNS Status:
```bash
adb shell settings get global private_dns_mode
adb shell settings get global private_dns_specifier
```

---

## Optimization 3: Anti-Lag & Background RAM Lockdown

Fire TV Sticks typically have only 1 GB to 1.5 GB of RAM. Heavy streaming apps keep background listeners alive even after you press Home or Back.

### 1. Cap Background Process Limit:
Restricts concurrent background tasks to prevent low-memory thrashing and ZRAM overflow:
```bash
adb shell settings put global standard_background_process_limit 2
```
> [!IMPORTANT]
> **Reboot Behavior Note**: Android's `ActivityManagerService` resets `standard_background_process_limit` to standard default upon system reboot. This is standard Android operating system behavior. You can re-apply this command anytime or leave it as default if you don't reboot frequently.

### 2. Disable Home Screen Video & Audio Autoplay:
Stops intrusive video ads and loud audio from playing when hovering over titles on the home carousel:
```bash
adb shell settings put global auto_play_video 0
adb shell settings put global auto_play_audio 0
```

### 3. AppOps RAM Lockdown for Heavy Streaming Apps:
Forces apps to surrender their memory and background execution privileges the instant you close them:
```bash
# Disney+ Hotstar
adb shell cmd appops set in.startv.hotstar RUN_IN_BACKGROUND ignore

# Netflix
adb shell cmd appops set com.netflix.ninja RUN_IN_BACKGROUND ignore

# Airtel Xstream
adb shell cmd appops set tv.airtel.xstream.tvapp RUN_IN_BACKGROUND ignore

# Sun NXT
adb shell cmd appops set com.suntv.sunnxt RUN_IN_BACKGROUND ignore

# Aha
adb shell cmd appops set ahaflix.tv RUN_IN_BACKGROUND ignore

# Crunchyroll
adb shell cmd appops set com.crunchyroll.crunchyroid RUN_IN_BACKGROUND ignore

# CrashManager background logger
adb shell cmd appops set com.amazon.device.crashmanager RUN_IN_BACKGROUND ignore
```
*(On Fire OS 5 / older Android where `cmd appops` is unavailable, use `adb shell appops set <pkg> RUN_IN_BACKGROUND ignore`)*

### 4. Trim Accumulated Cache Junk:
Reclaims cached thumbnails and stale buffers without deleting your user logins:
```bash
adb shell pm trim-caches 2G
```

---

## Optimization 4: 24 fps Cinema Frame Rate Matching

By default, Fire TV outputs at a fixed 60 Hz, creating 3:2 pulldown judder when playing 24 fps movies. This command enables native frame-rate matching in supported apps (Prime Video, Kodi, Plex, SmartTube):

```bash
adb shell settings put global match_content_frame_rate 1
```

### Verify Frame Rate Matching:
```bash
adb shell settings get global match_content_frame_rate
# Should output: 1
```

---

## System Verification & Diagnostics

Run these one-liners to inspect the health and state of your Fire TV:

```bash
# 1. Check Device Model & Fire OS Build:
adb shell getprop ro.product.model
adb shell getprop ro.build.version.name

# 2. Check Active Home Launcher (verifies launcher didn't crash):
adb shell "pm resolve-activity -a android.intent.action.MAIN -c android.intent.category.HOME"

# 3. Check Available Storage:
adb shell df -h /data

# 4. Check RAM & ZRAM Usage:
adb shell dumpsys meminfo | grep -E "Total RAM:|Free RAM:|Used RAM:|ZRAM:"

# 5. List All Currently Disabled Packages:
adb shell pm list packages -d
```

---

## Rollback & Reversal Commands

Every change made by this toolkit is 100% reversible. Use the commands below to restore any setting back to factory default.

### Re-enable Any Disabled Package:
```bash
adb shell pm enable <package_name>
```

### Re-enable All Debloated Packages in One Shot:
```bash
adb shell pm enable com.amazon.bueller.photos
adb shell pm enable com.amazon.bueller.music
adb shell pm enable com.amazon.recess
adb shell pm enable com.amazon.ods.kindleconnect
adb shell pm enable com.amazon.ceviche
adb shell pm enable com.amazon.ftv.screensaver
adb shell pm enable com.amazon.hybridadidservice
adb shell pm enable com.amazon.tv.acr
adb shell pm enable com.amazon.dp.logger
```

### Revert Ad-Blocking & Reset Private DNS to Automatic:
```bash
adb shell settings put secure limit_ad_tracking 0
adb shell settings put secure interest_based_ads 1
adb shell settings put global usage_metrics_marketing_enabled 1
adb shell settings put global private_dns_mode opportunistic
adb shell settings delete global private_dns_specifier
```

### Revert AppOps Background Restrictions:
```bash
adb shell cmd appops set in.startv.hotstar RUN_IN_BACKGROUND default
adb shell cmd appops set com.netflix.ninja RUN_IN_BACKGROUND default
adb shell cmd appops set tv.airtel.xstream.tvapp RUN_IN_BACKGROUND default
adb shell cmd appops set com.suntv.sunnxt RUN_IN_BACKGROUND default
adb shell cmd appops set ahaflix.tv RUN_IN_BACKGROUND default
adb shell cmd appops set com.crunchyroll.crunchyroid RUN_IN_BACKGROUND default
adb shell cmd appops set com.amazon.device.crashmanager RUN_IN_BACKGROUND default
```

### Revert Autoplay Settings:
```bash
adb shell settings put global auto_play_video 1
adb shell settings put global auto_play_audio 1
adb shell settings put global match_content_frame_rate 0
```

---

## Technical Deep Dive & FAQ

### Q: Why do some settings reset on reboot?
In Android OS architecture:
- **`pm disable-user --user 0 <pkg>`**: **PERMANENT across reboots**. Package state is saved to `/data/system/users/0/package-restrictions.xml`.
- **`settings put global private_dns_*`**: **PERMANENT across reboots**.
- **`settings put global auto_play_*`**: **PERMANENT across reboots**.
- **`cmd appops set <pkg> RUN_IN_BACKGROUND ignore`**: **PERMANENT across reboots**.
- **`standard_background_process_limit`**: **RESETS ON REBOOT**. In standard Android (including Fire OS), the `ActivityManagerService` does not persist developer process limits across power cycles. This is an Android OS design choice.

### Q: What happened with Fire OS 7.6.8.8?
Recent Fire OS updates (like `7.6.8.8`) include periodic Amazon background maintenance services that check for system components. However:
1. `pm disable-user --user 0` for consumer bloatware (Amazon Music, Recess, ACR, AdID) remains intact.
2. If Private DNS did not work for you previously, ensure you were not running an older version of the script that had a shell quoting bug on line 31 which halted execution before Private DNS was applied.
3. You can verify persistence at any time by running `adb shell pm list packages -d`.

### Q: Does this work on Fire OS 5 (Fire TV Stick 2nd Gen)?
Yes, with one exception:
- **Package Debloat**: Works (`pm disable-user --user 0`).
- **Autoplay / Process limit**: Works.
- **Private DNS**: Fire OS 5 is based on Android 5.1 Lollipop. Native Private DNS (DoT) was introduced in Android 9 (Fire OS 7). For Fire OS 5 or 6, set AdGuard DNS (`94.140.14.14`) in your router or Wi-Fi settings instead.
