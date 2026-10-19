# AI Agent Debloat & Optimization Prompt for Amazon Fire TV

> **Instructions for the AI Assistant / Coding Agent**:
> Copy and paste this prompt into any AI coding agent (Claude, Antigravity, ChatGPT, Cursor, etc.) to perform a safe, structured, and reversible debloat and optimization of an Amazon Fire TV device over ADB.

---

```markdown
# TASK: Safely Debloat, Optimize, and Ad-Block Amazon Fire TV via ADB

## 1. Operating Rules & Constraints (Non-Negotiable)
- **Rootless & Non-Destructive**: Use `pm disable-user --user 0` instead of deleting system packages.
- **Stock Launcher Integrity**: Do NOT attempt to disable the stock Amazon launcher (`com.amazon.tv.launcher`) unless explicitly instructed; Fire OS protects it, and bypassing it with accessibility services introduces navigation bounce.
- **Preserve Core Streaming & Auth**: Never disable Prime Video (`com.amazon.avod`), YouTube, Netflix, user-installed streaming apps, or their identity/authentication dependencies (`com.amazon.identity.*`, `com.amazon.imp`, `com.amazon.dcp`).
- **Preserve System Updates**: Do NOT block system updates (`com.amazon.device.software.ota`) unless explicitly verified.
- **Controlled Execution**: You MUST stop for explicit user approval before applying any package disables or modifications. Never apply changes in bulk without a baseline backup.

---

## 2. Phase 1: Connect & Baseline Inspection
1. Verify ADB availability (`adb version`).
2. Run `adb devices -l`. If not connected, request the Fire TV IP address and run:
   ```bash
   adb connect <FIRETV_IP>:5555
   ```
3. Prompt the user to check their TV screen to accept the "Always allow from this computer" prompt.
4. Extract and record a timestamped baseline in a local `baselines/` directory:
   - System properties (`getprop`)
   - Storage status (`df -h /data`)
   - Current launcher (`pm resolve-activity -a android.intent.action.MAIN -c android.intent.category.HOME`)
   - Package lists (`pm list packages -f`, `-e`, `-d`, `-s`, `-3`)
   - Memory breakdown (`dumpsys meminfo`)
   - Never overwrite existing backups.

---

## 3. Phase 2: Package Classification
Classify all discovered packages into 4 strict categories:
1. **Never Touch**: Core Android framework, Mediatek/Amlogic SoC drivers, Wi-Fi, Bluetooth remote control, keyboard IME (`com.amazon.tv.ime`), Settings, stock launcher, updater, identity/auth.
2. **Keep**: All user streaming applications, Amazon Appstore licensing (`com.amazon.venezia`), and display casting.
3. **Investigate**: Low-level metrics services (`com.amazon.client.metrics.api`, `com.amazon.adep`, `com.amazon.whisperlink.*`). *Rule: Do not disable packages merely because their names contain "metrics" or "analytics" without verifying dependencies.*
4. **Potentially Disable (Debloat Candidates)**: Verified optional standalone applications:
   - Casual trial games (`/data/app`)
   - Consumer background sync services (`com.amazon.bueller.photos`, `com.amazon.bueller.music`, `com.amazon.recess`, `com.amazon.ods.kindleconnect`)
   - Promotional aggregators (`com.amazon.ceviche`, `com.amazon.ftv.screensaver`)

---

## 4. Phase 3: Safety & Reversibility Plan
Prepare:
1. A categorized report with package name, function, RAM/storage footprint, risk level, confidence, and exact restore command.
2. An isolated batch execution script (`disable_batch.sh`).
3. An instant restore script (`restore_all.sh` using `pm enable`).
4. Stop and present the report to the user. **Wait for explicit user approval before proceeding.**

---

## 5. Phase 4: Controlled Execution & Verification
After user approval:
1. Apply approved packages in small batches using `pm disable-user --user 0 <pkg>`.
2. Verify ADB connectivity and launcher responsiveness after each batch.
3. Stop immediately if any anomalies occur.

---

## 6. Phase 5: Post-Debloat Performance Tuning
1. **App Cache Reclamation**: Reclaim buffer junk without clearing user logins:
   ```bash
   adb shell pm trim-caches 2G
   ```
2. **Permanent Game Bloat Removal**: Uninstall preloaded casual games from `/data/app` using `pm uninstall <pkg>` to free physical flash storage.
3. **AppOps Background Lockdown**: Prevent heavy streaming apps from running background tasks and hogging RAM when closed:
   ```bash
   adb shell cmd appops set <pkg> RUN_IN_BACKGROUND ignore
   ```
4. **Disable Carousel Autoplay**: Silence intrusive video and audio ads on the home screen:
   ```bash
   adb shell settings put global auto_play_video 0
   adb shell settings put global auto_play_audio 0
   ```
5. **Cap Background Processes**:
   ```bash
   adb shell settings put global standard_background_process_limit 2
   ```
6. **Network Ad-Blocking & ACR Disabling**:
   ```bash
   adb shell pm disable-user --user 0 com.amazon.tv.acr
   adb shell pm disable-user --user 0 com.amazon.hybridadidservice
   adb shell pm disable-user --user 0 com.amazon.dp.logger
   adb shell settings put secure limit_ad_tracking 1
   adb shell settings put secure interest_based_ads 0
   adb shell settings put global private_dns_mode hostname
   adb shell settings put global private_dns_specifier "dns.adguard.com"
   ```
7. **Cinema Frame Rate Matching**: Enable 24p cinema mode:
   ```bash
   adb shell settings put global match_content_frame_rate 1
   ```
8. **Final Clean Reboot**: Run `adb reboot`, reconnect, and verify health.
```
