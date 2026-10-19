# Fire TV Safe Debloat & Optimization Toolkit

A battle-tested, non-destructive, and 100% reversible optimization suite for **Amazon Fire TV devices (Fire OS 7 / Android 9)** using Linux and ADB.

Reclaims **1.4 GB+ of flash storage**, eliminates UI lag, caps background RAM hogs, silences home screen video ads, and configures device-wide ad-blocking—all while preserving your stock launcher, streaming apps, remote voice search, and system updates.

---

## ⚡ What This Toolkit Accomplishes

| Feature | Factory Default | After Optimization | Benefit |
|---|---|---|---|
| **Available Storage** | ~1.0 GB Free (79% Full) | **2.4 GB Free (50% Full)** | **+1.4 GB / 150% more space** |
| **ZRAM Swap Memory** | ~222 MB compressed swap | **~180 MB** | Reclaims ~40 MB RAM on a 1 GB device |
| **Background Memory Sinks** | Hotstar/Netflix eat 150MB+ in background | **`RUN_IN_BACKGROUND: ignore`** | Instant RAM release on app exit |
| **Home Carousel Video/Ads** | Loud video autoplays on hover | **Disabled & Silent** | Quiet browsing, zero GPU starvation |
| **Motion Cadence** | Fixed 60 Hz (3:2 pulldown judder) | **Match Original Frame Rate (24 fps)** | Cinema-smooth movie motion |
| **Ad & Tracker Blocking** | ACR fingerprinting & ad profiling | **AdGuard Private DNS Active** | Sinkholes ad domains to `127.0.0.1` |
| **Launcher Stability** | Heavy & sluggish | **Stock Launcher (Zero Bounce)** | Preserves native remote home button |

---

## 🛡️ Core Safety Principles

1. **Rootless & Non-Destructive**: Uses `pm disable-user --user 0 <pkg>` instead of dangerous system-partition uninstalls. Every change can be reversed with a single command.
2. **Preserves Prime Video & All Streaming Apps**: Leaves Prime Video (`com.amazon.avod`), YouTube, Netflix, Hotstar, Appstore, and user accounts completely untouched.
3. **No Bricking / No Broken Recovery**: Preserves all Bluetooth remote drivers, keyboard IME (`com.amazon.tv.ime`), Settings, Wi-Fi, audio/video HALs, and system update services.
4. **No Broken Launchers**: Avoids buggy accessibility remappers that cause screen flicker/bounces. Keeps the native stock launcher running fast.

---

## 📋 Prerequisites

- Linux laptop or PC with `adb` installed (`sudo apt install adb` or `sudo dnf install android-tools`).
- Amazon Fire TV Stick connected to the same local Wi-Fi network.
- **ADB Debugging enabled** on Fire TV:
  - Go to **Settings > My Fire TV > About > click device name 7 times** to unlock Developer Options.
  - Go to **Developer Options > ADB Debugging > Turn ON**.
- Note your Fire TV IP address (**Settings > My Fire TV > About > Network**).

---

## 🚀 Step-by-Step Usage

### 1. Connect over Wi-Fi
```bash
adb connect <FIRETV_IP>:5555
```
*Look at your TV screen and select **"Always allow from this computer"** $\rightarrow$ **OK**.*

### 2. Run the Safe Debloat Script
Disables non-essential background sync services (Amazon Photos, Amazon Music, Recess games hub, Live TV guide aggregator, and promo screensavers):
```bash
./scripts/1_debloat_packages.sh <FIRETV_IP>:5555
```

### 3. Apply Anti-Lag & Memory Optimization
Caps background processes at 2, disables home screen video/audio autoplays, locks down streaming app background memory via AppOps, and purges stale caches:
```bash
./scripts/4_anti_lag_tuning.sh <FIRETV_IP>:5555
```

### 4. Enable Ad-Blocking & Disable On-Screen Tracking
Sets encrypted AdGuard Private DNS (`dns.adguard.com`) and disables Automated Content Recognition (ACR) screen fingerprinting and Advertising ID cross-app tracking:
```bash
./scripts/2_enable_adblock.sh <FIRETV_IP>:5555
```

### 5. Enable 24 fps Cinema Frame Rate Matching
Enables native frame-rate matching so movies switch to 23.976 / 24.0 Hz refresh rates automatically:
```bash
./scripts/5_enable_cinema_mode.sh <FIRETV_IP>:5555
```

### 6. Verify System Health
Run a full diagnostic check showing storage, RAM, DNS mode, and active launcher:
```bash
./scripts/verify_health.sh <FIRETV_IP>:5555
```

### 7. Clean Reboot
```bash
adb -s <FIRETV_IP>:5555 reboot
```

---

## 🔄 Reversibility & Rollback

Every single change can be reverted instantly.

- **To re-enable all debloated packages**:
  ```bash
  ./scripts/6_restore_all.sh <FIRETV_IP>:5555
  ```
- **To revert Ad-Blocking back to default automatic DNS**:
  ```bash
  ./scripts/3_disable_adblock.sh <FIRETV_IP>:5555
  ```
- **To re-enable an individual package**:
  ```bash
  adb -s <FIRETV_IP>:5555 shell pm enable <package_name>
  ```

---

## 🤖 Reusable AI Agent Prompt

Looking to run this via Claude, Antigravity, ChatGPT, or Cursor? 
See [`AGENT_PROMPT.md`](./AGENT_PROMPT.md) for a ready-to-use prompt that guides any AI agent through the entire multi-phase debloat workflow with safety guardrails.

---

## 📄 License

MIT License. Feel free to use, modify, and share!
