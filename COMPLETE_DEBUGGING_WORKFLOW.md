# Complete Debugging Workflow - From PC to Logs

## Your Mission: Debug ExynosTools in Winlator

This guide connects all the pieces: WiFi setup → Logs → Analysis

---

## Prerequisites ✅

- [ ] PC with ADB installed (`adb` command works)
- [ ] Phone with USB Debugging enabled (Settings → Developer Options)
- [ ] Phone and PC on same WiFi network
- [ ] ExynosTools package installed in Winlator

---

## Phase 1: Setup WiFi ADB (One-Time)

### 1.1: Enable USB Debugging on Phone
```
PHONE: Settings → About Phone → Build Number (tap 7x)
PHONE: Settings → Developer Options → USB Debugging: ON
```

### 1.2: Initial USB Connection
```bash
# PC terminal:
adb devices

# On phone: tap "Allow" when prompted
adb devices
# Should show: AB123456    device
```

### 1.3: Enable WiFi Mode
```bash
# PC terminal (USB still connected):
adb tcpip 5555

# Output: restarting in TCP mode port: 5555
# NOW UNPLUG USB! 🔌
```

### 1.4: Connect via WiFi
```bash
# Get phone IP: Settings → WiFi → [Network] → IP Address
# Example: 192.168.1.100

# PC terminal:
adb connect 192.168.1.100:5555

# Output: connected to 192.168.1.100:5555
```

### 1.5: Verify Connection
```bash
adb devices

# Should show: 192.168.1.100:5555    device ✅
```

✅ **WiFi Setup Complete!** You can now do everything wireless!

---

## Phase 2: Capture Baseline Logs (No Game)

### 2.1: Clear Log Buffer
```bash
adb logcat -c
```

### 2.2: Start Capturing
```bash
adb logcat -s XenoWrapper:* > baseline.log
```

### 2.3: Wait 5 Seconds
Just let it run and capture any startup messages.

### 2.4: Stop (Ctrl+C)
```
Ctrl+C
```

### 2.5: Review Baseline
```bash
cat baseline.log
```

**You should see:**
```
I XenoWrapper: ExynosTools logging initialized (Android logcat mode)
```

✅ **Confirms logging is working!**

---

## Phase 3: Test with Game - Menu Glitch

This is where you debug the glitches you saw!

### 3.1: Prepare Logging
```bash
# Terminal 1: Start fresh log
adb logcat -c
adb logcat -s XenoWrapper:* > elden_ring_menu.log

# This terminal stays running!
```

### 3.2: Launch Game
```bash
# In another terminal or on phone:
# Open Winlator → Launch Elden Ring
```

### 3.3: Trigger the Glitch
1. Let the game load completely
2. Go to the **Character Menu** (where you saw glitches before)
3. Navigate around for 30 seconds
4. Go back to main area

### 3.4: Stop Logging
```bash
# Terminal 1: Ctrl+C to stop logging
Ctrl+C
```

### 3.5: Analyze the Log
```bash
cat elden_ring_menu.log | tail -n 50
```

**Look for patterns:**

#### Pattern 1: Normal Decoding
```
I XenoWrapper: bc_emulate: Decoding texture 512x512 using format BC5 (id=1)
I XenoWrapper: bc_emulate: ✓ Successfully decompressed 512x512 texture (format=1)
```
→ This format works!

#### Pattern 2: Missing Format
```
E XenoWrapper: bc_emulate: Unsupported format requested: 99
E XenoWrapper: bc_emulate: Unsupported format requested: 99
E XenoWrapper: bc_emulate: Unsupported format requested: 99
```
→ BC7 is needed! (Format 99 = BC7)

#### Pattern 3: Vulkan Error
```
E XenoWrapper: bc_emulate: Failed to create pipeline: VkResult=-1000012000
```
→ Pipeline creation failed

---

## Phase 4: Detailed Analysis - Enable Debug Logs

If you want **super detailed** logs, enable debug mode!

### 4.1: Enable Debug in Winlator
In Winlator container settings, add environment variable:
```
EXYNOSTOOLS_DEBUG=1
```

Restart the container.

### 4.2: Capture with Debug Logs
```bash
adb logcat -c
adb logcat -s XenoWrapper:* > elden_ring_debug.log
```

### 4.3: Play Game
Repeat Phase 3 steps

### 4.4: Review Debug Logs
```bash
cat elden_ring_debug.log | tail -n 100
```

**Now you'll see:**
```
D XenoWrapper: bc_emulate: Block calculation - blocksPerRow=256, dispatch=256x256
D XenoWrapper: bc_emulate: Dispatching compute shader for 65536 blocks
D XenoWrapper: bc_emulate: Allocating descriptor set for BC4 decompression
```

---

## Phase 5: Diagnosis - What Do the Logs Tell You?

### Question 1: Are BC4/BC5 working?

```bash
# Check if BC4/BC5 textures decompress successfully:
grep "Successfully decompressed" elden_ring_menu.log | wc -l

# Result: Shows number of successful decompressions
# > 0 means BC4/BC5 is working!
```

### Question 2: What formats does the game use?

```bash
# Find all format requests:
grep -o "format BC[0-9]" elden_ring_menu.log | sort | uniq -c

# Example output:
#   15 format BC4
#   42 format BC5
#   0 format BC6
#   0 format BC7
```

### Question 3: Are there unsupported formats?

```bash
# Find unsupported format errors:
grep "Unsupported format" elden_ring_menu.log

# Example:
# E XenoWrapper: bc_emulate: Unsupported format requested: 99
# E XenoWrapper: bc_emulate: Unsupported format requested: 99
```

### Question 4: Are there Vulkan errors?

```bash
# Find all errors:
grep "\[E\]" elden_ring_menu.log

# Or look for specific Vulkan errors:
grep "Failed" elden_ring_menu.log
```

---

## Phase 6: Share Findings

### 6.1: Create Summary
```bash
# Count stats:
echo "=== BC Decoding Stats ==="
echo "Successful BC4 decompressions: $(grep 'format BC4' elden_ring_menu.log | wc -l)"
echo "Successful BC5 decompressions: $(grep 'format BC5' elden_ring_menu.log | wc -l)"
echo "Unsupported formats: $(grep 'Unsupported format' elden_ring_menu.log | wc -l)"
echo "Vulkan errors: $(grep '\[E\]' elden_ring_menu.log | wc -l)"
```

### 6.2: Share with Me
Share:
- `elden_ring_menu.log` (the full log)
- Output of the summary script above
- Description of visual glitches you see

---

## Automated Testing Script

Here's a bash script to automate the whole process:

```bash
#!/bin/bash
# test_exynostools.sh

echo "=== ExynosTools Testing ==="

# Get phone IP
read -p "Enter phone IP (e.g., 192.168.1.100): " PHONE_IP

# Clear logs
echo "Clearing logcat..."
adb -s $PHONE_IP:5555 logcat -c

# Start capturing
LOG_FILE="exynostools_test_$(date +%Y%m%d_%H%M%S).log"
echo "Capturing logs to: $LOG_FILE"
echo "Open Winlator and launch game NOW (30 seconds to play)..."

adb -s $PHONE_IP:5555 logcat -s XenoWrapper:* > $LOG_FILE &
LOG_PID=$!

# Wait 30 seconds
sleep 30

# Stop capturing
kill $LOG_PID
wait $LOG_PID 2>/dev/null

# Analyze
echo ""
echo "=== Analysis ==="
echo "Total lines: $(wc -l < $LOG_FILE)"
echo ""
echo "BC4 decompressions: $(grep 'format BC4' $LOG_FILE | wc -l)"
echo "BC5 decompressions: $(grep 'format BC5' $LOG_FILE | wc -l)"
echo "Unsupported formats: $(grep 'Unsupported format' $LOG_FILE | wc -l)"
echo "Vulkan errors: $(grep 'Failed\|Error' $LOG_FILE | wc -l)"
echo ""
echo "Full log saved to: $LOG_FILE"
echo ""
echo "=== Last 20 lines (most recent) ==="
tail -n 20 $LOG_FILE
```

**Usage:**
```bash
chmod +x test_exynostools.sh
./test_exynostools.sh
```

---

## Quick Checklist

After you capture logs:

- [ ] Do you see `"logging initialized (Android logcat mode)"`?
- [ ] Do you see BC4/BC5 texture decoding messages?
- [ ] Do you see any "Unsupported format" errors?
- [ ] Do you see any Vulkan errors?
- [ ] Did you count how many of each?

**Once you have these answers, you know what to fix!**

---

## Next Steps After Debugging

### If you see many "Unsupported format: 99" errors:
→ **BC7 is missing** - This is the most likely issue!

### If you see many "Unsupported format: 98" errors:
→ **BC6H is missing** - Less common but important for HDR

### If you see errors but BC4/BC5 succeed:
→ **BC4/BC5 have bugs** - Need to debug shader formulas

### If everything succeeds but glitches remain:
→ **Other issue** - Could be descriptor indexing, robustness, etc.

---

## Summary

```
Your Debugging Journey:
1. ✅ Setup WiFi ADB
2. ✅ Capture logs from game
3. ✅ Analyze: Which formats used?
4. ✅ Identify: What's missing?
5. ✅ Report: Share findings
6. → We implement the fix!
```

**Ready to debug?** Start from Phase 1! 🚀
