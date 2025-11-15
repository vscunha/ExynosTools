# ADB WiFi Setup - Complete Guide

## What is ADB WiFi?

ADB (Android Debug Bridge) normally uses USB, but you can use it over WiFi instead. This lets you:
- ✅ See logs from Termux or PC terminal
- ✅ Push/pull files from phone
- ✅ Debug apps remotely
- ✅ No USB cable needed!

---

## Prerequisites

### On Your PC:
- ADB installed (`adb` command available)
- Same WiFi network as phone

### On Your Phone:
- USB debugging enabled (even for WiFi, you need this initially)
- Android 10+
- Same WiFi network as PC

---

## Step 1: Enable USB Debugging (One-Time Setup)

### On Your Android Phone:

1. **Open Settings**
2. **Go to: About Phone**
3. **Find "Build Number"** - Tap it **7 times** rapidly
   - You'll see: "You are now a developer!"
4. **Go back to Settings**
5. **Find "Developer Options"** (new menu that appeared)
6. **Enable "USB Debugging"**
   - You'll see a dialog: "Allow USB debugging?"
   - Tap "Allow"

**That's it! USB debugging is now enabled. You only do this once.**

---

## Step 2: Connect PC and Phone via USB (Initial Connection Only)

This is just to get the WiFi connection set up. After this, you can unplug the cable!

### On Your PC Terminal:

```bash
# Verify ADB sees your phone
adb devices

# You should see something like:
# List of attached devices
# emulator-5554          device
# AB123456               device    <- Your phone
```

If your phone shows `unauthorized`:
- Look at your phone screen
- Tap "Allow" on the USB debugging prompt
- Run `adb devices` again

---

## Step 3: Find Your Phone's WiFi IP Address

### Option A: From Your Phone Settings

1. **Settings → WiFi**
2. **Long-press your WiFi network**
3. **Tap "Manage"** (or similar option depending on Android version)
4. **Look for "IP address"** - it looks like `192.168.x.x` or `10.0.x.x`

**Write down this IP address!** Example: `192.168.1.100`

### Option B: From PC Terminal (While USB Connected)

```bash
adb shell ip addr show wlan0 | grep "inet "
```

Output example:
```
inet 192.168.1.100/24 scope global dynamic wlan0
```

Your IP is `192.168.1.100`

---

## Step 4: Enable ADB WiFi on Your Phone

### While Phone is Connected via USB:

On your PC terminal, run:

```bash
# Enable WiFi debugging on port 5555 (standard port)
adb tcpip 5555

# Output should be:
# restarting in TCP mode port: 5555
```

**Now you can unplug the USB cable!** 🔌

---

## Step 5: Connect via WiFi

### On Your PC Terminal:

```bash
# Replace 192.168.1.100 with your phone's actual IP
adb connect 192.168.1.100:5555

# You should see:
# connected to 192.168.1.100:5555
```

### Verify Connection:

```bash
adb devices

# You should see:
# List of attached devices
# 192.168.1.100:5555    device    <- Your phone via WiFi!
```

**If it shows `unauthorized`:**
- Check your phone screen
- A dialog should appear asking to allow WiFi debugging
- Tap "Allow"
- Run `adb devices` again

---

## Step 6: Start Viewing Logs! 

### View ExynosTools Logs:

```bash
adb logcat -s XenoWrapper:*
```

### Now Test It:

1. **Keep the logcat command running** in your terminal
2. **Open Winlator on your phone**
3. **Launch a game**
4. **Watch the logs appear in real-time!** 🎉

Example output:
```
I XenoWrapper: ExynosTools logging initialized (Android logcat mode)
I XenoWrapper: bc_emulate: Initializing BC texture decompression context
I XenoWrapper: bc_emulate: Creating BC4 shader module
I XenoWrapper: bc_emulate: ✓ BC4 pipeline created successfully
I XenoWrapper: bc_emulate: Decoding texture 1024x1024 using format BC4 (id=0)
I XenoWrapper: bc_emulate: ✓ Successfully decompressed 1024x1024 texture (format=0)
E XenoWrapper: bc_emulate: Unsupported format requested: 99
```

---

## Useful ADB WiFi Commands

### Clear Log Buffer:
```bash
adb logcat -c
```

### Save Logs to File:
```bash
adb logcat -s XenoWrapper:* > xeno_logs.txt
```

### View All Logs (not just XenoWrapper):
```bash
adb logcat
```

### Stop ADB WiFi (Switch Back to USB or Disconnect):
```bash
adb disconnect
```

### Reconnect to Same Phone:
```bash
adb connect 192.168.1.100:5555
```

### Find All Connected Devices:
```bash
adb devices -l
```

---

## Troubleshooting

### Problem: `adb: command not found`
**Solution:** ADB not installed
```bash
# Ubuntu/Debian:
sudo apt install adb

# macOS (with Homebrew):
brew install android-platform-tools

# Windows: Download from https://developer.android.com/tools/releases/platform-tools
```

### Problem: `failed to connect to 192.168.1.100:5555`
**Possible causes:**
1. Wrong IP address - recheck in phone Settings
2. Phone and PC not on same WiFi network
3. Firewall blocking port 5555
4. Phone WiFi debugging not enabled - re-run `adb tcpip 5555` with USB

**Try:**
```bash
# Re-enable WiFi debugging
adb tcpip 5555
adb connect 192.168.1.100:5555
```

### Problem: `unauthorized` or `offline`
**Solution:**
1. Check your phone screen for debugging prompt
2. Tap "Allow"
3. Run `adb devices` again

### Problem: No logs appearing
**Check:**
```bash
# Verify connection
adb devices

# Should show: 192.168.1.100:5555    device

# If it shows "offline":
adb reconnect
```

### Problem: Connection drops frequently
**Solution:** WiFi debugging is stable but if it keeps dropping:
1. Move closer to WiFi router
2. Reduce WiFi interference
3. Try USB cable again for comparison

---

## Quick Reference

### Initial Setup (One Time):
```bash
# 1. Enable USB debugging in phone Settings → Developer Options
# 2. Connect phone via USB
adb tcpip 5555
# 3. Get phone IP from Settings → WiFi → Network details
# 4. Disconnect USB
adb connect 192.168.1.100:5555  # Replace with your IP
```

### Daily Use:
```bash
# Just run:
adb connect 192.168.1.100:5555  # If reconnecting after restart
adb logcat -s XenoWrapper:*
```

### Stop Using WiFi ADB:
```bash
adb disconnect
# Or reconnect USB and run: adb usb
```

---

## Pro Tips

### 1. Alias for Quick Connection
Add to your `~/.bashrc` or `~/.zshrc`:
```bash
alias adb-wifi='adb connect 192.168.1.100:5555'
alias adb-logs='adb logcat -s XenoWrapper:*'
alias adb-clear='adb logcat -c'
```

Then just type:
```bash
adb-wifi
adb-logs
```

### 2. Save Logs While Testing
```bash
# Terminal 1: Start logging to file
adb logcat -s XenoWrapper:* > test_run.log

# Terminal 2: Open another terminal and play game
# Game plays...

# Ctrl+C in Terminal 1 to stop, then:
cat test_run.log | less  # View the logs
```

### 3. Real-Time Filtering
```bash
# Show only errors:
adb logcat -s XenoWrapper:E

# Show everything EXCEPT debug:
adb logcat -s "XenoWrapper:!D"

# Show only format-related errors:
adb logcat -s XenoWrapper:* | grep -i format
```

### 4. Monitor Multiple Things:
```bash
# XenoWrapper + Vulkan errors + crashes:
adb logcat -s XenoWrapper:* | grep -E "XenoWrapper|VULKAN|crash|ANR"
```

---

## What's Next?

Once you have logs running:

1. **Play your game for a few minutes**
2. **Look at the logs** - specifically:
   - Are BC4/BC5 being decoded? → `"Decoding texture"` messages
   - Are unsupported formats shown? → `"Unsupported format requested: 98"` (BC6H) or `99` (BC7)
   - Any errors? → Look for `[E]` (Error) lines

3. **Share the logs with me** and I can help diagnose:
   - If BC4/BC5 have bugs
   - If BC6H/BC7 are missing
   - What's causing the glitches

---

## Summary

✅ **USB Debugging**: Enable once in phone settings  
✅ **ADB tcpip**: Connect to WiFi debugging  
✅ **ADB connect**: Connect from PC to phone  
✅ **adb logcat**: View logs in real-time  
✅ **No USB cable**: After initial setup, wireless only!

**You're ready to debug!** 🚀
