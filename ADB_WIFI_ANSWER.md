# ADB WiFi - Your Specific Question Answered

## "How do I do this using ADB WiFi?"

Great question! Here's the shortest possible answer:

---

## The 30-Second Version

```bash
# Step 1: On PHONE - Enable USB Debugging
Settings → Developer Options → USB Debugging: ON

# Step 2: On PC - Connect USB and enable WiFi
adb tcpip 5555
# (Unplug USB after this)

# Step 3: On PC - Connect via WiFi
adb connect 192.168.1.100:5555  # Replace with your phone's IP

# Step 4: On PC - View logs in real-time
adb logcat -s XenoWrapper:*

# Step 5: On PHONE - Open Winlator and launch game
# Watch logs appear on your PC in real-time!
```

**That's it! No USB cable needed after Step 2.** 🎉

---

## How to Find Your Phone's IP

### Option A: From Phone Settings
```
Settings → WiFi → [Your WiFi Name] → Manage/Details
Look for: IP Address (e.g., 192.168.1.100)
```

### Option B: From PC (while USB connected)
```bash
adb shell ip addr show wlan0
# Look for: inet 192.168.1.100/24
```

---

## Why ADB WiFi is Better

| Method | Pros | Cons |
|--------|------|------|
| **USB** | Always works | Cable tethered to phone |
| **WiFi** | Free to move around | Need initial USB connection |

---

## Quick Troubleshooting

### If `adb connect` fails:
```bash
# 1. Check IP is correct (Settings → WiFi → Details)
# 2. Make sure USB still enabled in Developer Options
# 3. Reconnect USB and re-run:
adb tcpip 5555
# (unplug USB)
adb connect 192.168.1.100:5555
```

### If connection shows "unauthorized":
- Look at your phone screen
- A popup should appear asking to allow debugging
- Tap "Allow"
- Run `adb devices` again

### If no logs appear:
```bash
adb devices
# Should show: 192.168.1.100:5555    device

# If shows "offline":
adb reconnect
```

---

## Reference: All ADB WiFi Commands

```bash
# Setup (do once, with USB):
adb tcpip 5555

# Connect (after unplugging USB):
adb connect 192.168.1.100:5555

# View logs:
adb logcat -s XenoWrapper:*

# Save logs to file:
adb logcat -s XenoWrapper:* > logs.txt

# Reconnect after phone restart:
adb connect 192.168.1.100:5555

# Stop WiFi (back to USB or disconnect):
adb disconnect

# Check status:
adb devices
```

---

## Pro Tip: Create an Alias

Add this to your `~/.bashrc` or `~/.zshrc`:

```bash
# Replace 192.168.1.100 with YOUR phone's IP
alias adb-wifi='adb connect 192.168.1.100:5555'
alias adb-logs='adb logcat -s XenoWrapper:*'
alias adb-clear='adb logcat -c'
```

Then you can just type:
```bash
adb-wifi    # Quick reconnect
adb-logs    # Start viewing logs
adb-clear   # Clear the log buffer
```

---

## Your Workflow

```
1. ONE TIME SETUP:
   adb tcpip 5555
   adb connect 192.168.1.100:5555

2. DAILY USE:
   adb connect 192.168.1.100:5555  # If needed after restart
   adb logcat -s XenoWrapper:*      # Start viewing logs

3. OPEN WINLATOR:
   Launch game
   Watch logs appear on PC
   🎉 Done!

4. SAVE LOGS:
   adb logcat -s XenoWrapper:* > test_run.log
   # Play for 1-2 minutes
   # Ctrl+C to stop
   # cat test_run.log to view
```

---

## Next Steps

✅ Set up WiFi ADB (use the 30-second version above)
✅ Verify connection works: `adb devices` should show your IP
✅ View logs: `adb logcat -s XenoWrapper:*`
✅ Follow: `COMPLETE_DEBUGGING_WORKFLOW.md` to run actual tests
✅ Share results with me!

---

## That's Everything You Need!

For more details, see the other guides:
- `ADB_WIFI_QUICK.md` - Commands only
- `ADB_WIFI_SETUP.md` - Full step-by-step with explanations
- `ADB_WIFI_VISUAL.md` - Visual diagrams and flowcharts
- `GUIDES_INDEX.md` - Index of all documentation

**You're ready to start debugging!** 🚀
