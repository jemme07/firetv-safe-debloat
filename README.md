# Fire TV Safe Debloat & Optimization Toolkit

A battle-tested, non-destructive, and 100% reversible optimization suite for **Amazon Fire TV devices** (Fire TV Stick, Cube, and Fire OS Smart TVs) using ADB on **Linux, macOS, and Windows**.

Reclaims **1.4 GB+ of flash storage**, eliminates UI lag, caps background RAM hogs, silences home screen video ads, and configures device-wide ad-blocking—all while preserving your stock launcher, streaming apps, remote voice search, and system updates.

> [!TIP]
> **Prefer running commands manually?**
> If you don't want to run automated scripts and prefer copy-pasting raw ADB commands directly, see the **[DIY Manual ADB Commands Guide](./MANUAL_COMMANDS.md)**.

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
| **Launcher Stability** | Sluggish & bloated | **Stock Launcher (Zero Bounce)** | Preserves native remote home button |

---

## 📱 Device & OS Compatibility Matrix

| Fire OS Version | Base Android | Example Devices | Package Debloat | Anti-Lag / Autoplay | Private DNS (DoT) |
|---|---|---|:---:|:---:|:---:|
| **Fire OS 5** (`5.2.x.x`) | Android 5.1 (Lollipop) | Fire TV Stick 2nd Gen | ✅ Fully Supported | ✅ Fully Supported | ⚠️ Router/Wi-Fi DNS only* |
| **Fire OS 6** (`6.2.x.x`) | Android 7.1 (Nougat) | Fire TV Stick 4K (1st Gen), Cube (1st Gen) | ✅ Fully Supported | ✅ Fully Supported | ⚠️ Router/Wi-Fi DNS only* |
| **Fire OS 7** (`7.6.x.x`) | Android 9 (Pie) | Fire TV Stick 3rd Gen, Lite, 4K Max (1st Gen), Cube 2nd Gen, Smart TVs (Panasonic, Insignia, Toshiba, Omni) | ✅ Fully Supported | ✅ Fully Supported | ✅ Fully Supported |
| **Fire OS 8** (`8.1.x.x`) | Android 11 (Red Velvet Cake) | Fire TV Stick 4K (2nd Gen), 4K Max (2nd Gen), Cube 3rd Gen | ✅ Fully Supported | ✅ Fully Supported | ✅ Fully Supported |

*\*Note: Native Android Private DNS (DNS-over-TLS) was introduced in Android 9 (Fire OS 7+). For Fire OS 5 and 6 devices, configure AdGuard DNS (`94.140.14.14`) directly in your Wi-Fi router or TV Wi-Fi IP settings.*

---

## 🛡️ Core Safety Principles

1. **Rootless & Non-Destructive**: Uses `pm disable-user --user 0 <pkg>` instead of dangerous system-partition uninstalls. Every change can be reversed with a single command.
2. **Preserves Prime Video & All Streaming Apps**: Leaves Prime Video (`com.amazon.avod`), YouTube, Netflix, Hotstar, Appstore, and user accounts completely untouched.
3. **No Bricking / No Broken Recovery**: Preserves all Bluetooth remote drivers, keyboard IME (`com.amazon.tv.ime`), Settings, Wi-Fi, audio/video HALs, and system update services.
4. **No Broken Launchers**: Avoids buggy accessibility remappers that cause screen flicker/bounces. Keeps the native stock launcher running fast.
5. **Screensaver Friendly**: Want personal photos cycling on your screensaver? Pass `--keep-photos` to keep Amazon Photos enabled.

---

## 📋 Prerequisites

### 1. Enable ADB Debugging on Fire TV
- Go to **Settings > My Fire TV > About**.
- Highlight your device name and **click the Select button 7 times** to unlock Developer Options.
- Go back to **Developer Options > ADB Debugging > Turn ON**.
- Note your Fire TV IP address (**Settings > My Fire TV > About > Network**).

### 2. Install ADB on your Computer
- **Linux**: `sudo apt install adb` or `sudo dnf install android-tools`
- **macOS**: `brew install android-platform-tools`
- **Windows**: Run `winget install Google.PlatformTools` in PowerShell, or download [Android SDK Platform-Tools](https://developer.android.com/tools/releases/platform-tools).

---

## 🚀 Quick Start (Automated Scripts)

### Option A: Linux & macOS (Bash)

#### 1. Connect to Fire TV over Wi-Fi
```bash
adb connect <FIRETV_IP>:5555
```
*Look at your TV screen and select **"Always allow from this computer"** $\rightarrow$ **OK**.*

#### 2. Run Safe Debloat
```bash
# Standard debloat
./scripts/1_debloat_packages.sh <FIRETV_IP>:5555

# OR if you use Amazon Photos for your ambient/screensaver:
./scripts/1_debloat_packages.sh <FIRETV_IP>:5555 --keep-photos
```

#### 3. Apply Anti-Lag & Memory Optimization
```bash
./scripts/4_anti_lag_tuning.sh <FIRETV_IP>:5555
```

#### 4. Enable Ad-Blocking & Privacy Hardening
```bash
./scripts/2_enable_adblock.sh <FIRETV_IP>:5555
```

#### 5. Enable 24 fps Cinema Frame Rate Matching
```bash
./scripts/5_enable_cinema_mode.sh <FIRETV_IP>:5555
```

#### 6. Verify System Health
```bash
./scripts/verify_health.sh <FIRETV_IP>:5555
```

---

### Option B: Windows 10 & 11 (Batch / CMD)

Native batch scripts are provided in the [`windows/`](./windows/) directory. You can either double-click them in File Explorer or run them from Command Prompt / PowerShell:

```cmd
:: 1. Connect over Wi-Fi
adb connect <FIRETV_IP>:5555

:: 2. Run Safe Debloat (or pass --keep-photos to retain photo screensaver)
windows\1_debloat_packages.bat <FIRETV_IP>:5555

:: 3. Apply Anti-Lag & Memory Optimization
windows\4_anti_lag_tuning.bat <FIRETV_IP>:5555

:: 4. Enable Ad-Blocking (AdGuard DNS)
windows\2_enable_adblock.bat <FIRETV_IP>:5555

:: 5. Enable 24 fps Cinema Frame Rate Matching
windows\5_enable_cinema_mode.bat <FIRETV_IP>:5555

:: 6. Verify System Health
windows\verify_health.bat <FIRETV_IP>:5555
```

---

### Option C: DIY Manual Commands (No Scripts)

If you prefer to audit and run each command yourself, check out our **[DIY Manual ADB Commands Guide](./MANUAL_COMMANDS.md)** with copy-pasteable commands for every optimization.

---

## 🔄 Reversibility & Rollback

Every change can be reverted instantly back to factory settings.

### Linux / macOS:
- **Re-enable all debloated packages**:
  ```bash
  ./scripts/6_restore_all.sh <FIRETV_IP>:5555
  ```
- **Revert Ad-Blocking & Private DNS**:
  ```bash
  ./scripts/3_disable_adblock.sh <FIRETV_IP>:5555
  ```

### Windows:
- **Re-enable all debloated packages**:
  ```cmd
  windows\6_restore_all.bat <FIRETV_IP>:5555
  ```
- **Revert Ad-Blocking & Private DNS**:
  ```cmd
  windows\3_disable_adblock.bat <FIRETV_IP>:5555
  ```

### Re-enable an Individual Package:
```bash
adb -s <FIRETV_IP>:5555 shell pm enable <package_name>
```

---

## ❓ Frequently Asked Questions (FAQ)

### What persists across a reboot vs. what resets?
- **Disabled packages (`pm disable-user --user 0`)**: **PERMANENT**. Persists across reboots.
- **Private DNS (`private_dns_mode`)**: **PERMANENT**. Persists across reboots.
- **Home Carousel Autoplay (`auto_play_video / auto_play_audio`)**: **PERMANENT**.
- **AppOps Background Restrictions (`cmd appops set <pkg> RUN_IN_BACKGROUND ignore`)**: **PERMANENT**.
- **Background Process Limit (`standard_background_process_limit`)**: **RESETS ON REBOOT**. In standard Android, the `ActivityManagerService` resets this developer toggle back to standard default upon system boot. You can re-apply this command whenever you want or leave it at system default.

### What about Fire OS 7.6.8.8?
On Fire OS `7.6.8.8`, `pm disable-user --user 0` continues to work cleanly for standalone bloatware (Amazon Music, Recess, ACR, AdID, Live TV guide). If Private DNS did not work for you in a previous release, note that an earlier typo on script line 31 has been resolved. You can verify active DNS and disabled packages anytime with `verify_health.sh` or `verify_health.bat`.

### Will this remove my personal photo screensaver?
If you enjoy having personal photos cycle on your screensaver (common on Panasonic, Insignia, and Omni TVs), simply add `--keep-photos` when running `1_debloat_packages.sh` (or skip `com.amazon.bueller.photos` in manual mode).

---

## 🤖 Reusable AI Agent Prompt

Looking to run this via Claude, Antigravity, ChatGPT, or Cursor? 
See [`AGENT_PROMPT.md`](./AGENT_PROMPT.md) for a ready-to-use prompt that guides any AI agent through the multi-phase debloat workflow with safety guardrails.

---

## 📄 License

MIT License. Free to use, modify, and share!
