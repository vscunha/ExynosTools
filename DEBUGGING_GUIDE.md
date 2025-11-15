# 🐛 Debugging Guide for GameHub/Android

## 📱 How to Read Logs from Your Custom Driver

Your ExynosTools driver writes logs to Android's **logcat** system. Here's how to read them!

---

## 🔧 Method 1: Using ADB (Recommended - Most Detailed)

### Prerequisites
- USB cable to connect phone to computer
- ADB installed on your computer

### Step-by-Step:

#### 1. Install ADB on Your Computer

**Linux/Ubuntu:**
```bash
sudo apt install adb
```

**Windows:**
- Download from: https://developer.android.com/studio/releases/platform-tools
- Extract and add to PATH

**Mac:**
```bash
brew install android-platform-tools
```

#### 2. Enable Developer Mode on Your Phone

1. Go to **Settings** → **About Phone**
2. Tap **Build Number** 7 times (enables Developer Options)
3. Go back to **Settings** → **Developer Options**
4. Enable **USB Debugging**

#### 3. Connect Your Phone

```bash
# Connect phone via USB
# On phone: Accept USB debugging prompt

# Verify connection
adb devices

# Should show something like:
# List of devices attached
# ABC123456789    device
```

#### 4. Read Logs in Real-Time

```bash
# Clear old logs first
adb logcat -c

# Start reading logs from your driver
adb logcat -s "XenoWrapper:*" "bc_emulate:*"
```

This will show output like:
```
11-08 21:30:45.123  1234  5678 I XenoWrapper: bc_emulate: context created successfully
11-08 21:30:45.456  1234  5678 D XenoWrapper: bc_emulate: decoded 1024x1024 texture using format 0
```

#### 5. Filter and Save Logs

```bash
# Save all logs to file
adb logcat > gamehub_logs.txt

# Filter only your driver logs
adb logcat -s "XenoWrapper:*" | tee driver_logs.txt

# Show only errors
adb logcat -s "XenoWrapper:E"
```

---

## 📱 Method 2: Using Android Apps (No Computer Needed)

### Option A: Logcat Reader (Free App)

1. Install **"Logcat Reader"** from Play Store
2. Grant it permission to read logs
3. Open the app
4. Filter by: `XenoWrapper` or `bc_emulate`
5. You'll see your driver logs!

### Option B: MatLog (Advanced)

1. Install **"MatLog"** from Play Store  
2. More features: save logs, search, filters
3. Search for "XenoWrapper" to find your messages

---

## 🔍 What to Look For in Logs

### Success Messages:
```
I XenoWrapper: bc_emulate: context created successfully with BC4/BC5 support
D XenoWrapper: bc_emulate: decoded 512x512 texture using format 0
```

### Error Messages:
```
E XenoWrapper: bc_emulate: failed to create BC4 shader module: -3
E XenoWrapper: bc_emulate: context not initialized
E XenoWrapper: bc_emulate: unsupported format 2
```

### What Each Means:

- **"context created"** = Driver loaded successfully ✅
- **"decoded NxN texture using format X"** = Decompression working ✅
- **"format 0"** = BC4
- **"format 1"** = BC5
- **"failed to create shader"** = Shader compilation issue ❌
- **"unsupported format X"** = Game trying to use BC6H/BC7 ❌

---

## 🎯 Debugging BC4/BC5 Issues

### Add More Debug Info

To see exactly what's being decompressed, we can add logs like:

```c
// In bc_emulate.c, xeno_bc_decode_image function
XENO_LOGI("bc_emulate: Decoding %dx%d texture, format=%d, blocks=%dx%d", 
          extent.width, extent.height, format, groupsX, groupsY);
```

### Important Values to Log:

1. **Texture dimensions** - Are they correct?
2. **Format being used** - BC4=0, BC5=1
3. **Number of blocks** - Should match texture size / 4
4. **Success/failure** - Did decompression complete?

---

## 🚀 Live Debugging While Playing

### Terminal 1: Watch Logs
```bash
adb logcat -s "XenoWrapper:*" -v time
```

### Terminal 2: Monitor Errors Only  
```bash
adb logcat -s "XenoWrapper:E" -v time
```

### What to Do:
1. Start watching logs
2. Launch GameHub
3. Start Elden Ring
4. Watch logs as game loads
5. Note any errors when glitches appear

---

## 📊 Analyzing Patterns

### Pattern 1: No Logs at All
**Problem**: Driver not loading  
**Fix**: Check GameHub has driver enabled

### Pattern 2: "context created" but no "decoded" messages
**Problem**: Game not using BC4/BC5  
**Meaning**: Glitches are from BC6H/BC7!

### Pattern 3: Many "decoded" messages but glitches
**Problem**: BC4/BC5 decompression has bugs  
**Action**: We need to fix the shaders!

### Pattern 4: "unsupported format" errors
**Problem**: Game using BC6H/BC7  
**Action**: Need to implement those formats

---

## 🛠️ Advanced: Adding Custom Debug Logs

### In bc_emulate.c, add detailed logging:

```c
// Before decompression
XENO_LOGD("bc_emulate: Block info - width=%d, height=%d, blocksPerRow=%d", 
          extent.width, extent.height, pushConstants[2]);

// After decompression  
XENO_LOGD("bc_emulate: Decompression dispatched - groups: %dx%d", 
          groupsX, groupsY);
```

### Rebuild and Repackage:
```bash
cd build
make
cd ..
bash package_winlator.sh
```

### Reinstall on device and test again!

---

## 📸 Screenshot Your Glitches + Logs

This helps debugging:

1. Take screenshot of glitch in game
2. At same moment, save logs:
   ```bash
   adb logcat -d > glitch_moment.txt
   ```
3. Compare: what was being decompressed when glitch appeared?

---

## 🎮 GameHub-Specific Tips

### Finding GameHub's Logs:
```bash
# See what GameHub is doing
adb logcat -s "GameHub:*"

# See Vulkan loader messages
adb logcat -s "vulkan:*"
```

### Check if Driver is Active:
```bash
adb logcat | grep -i "xeno\|wrapper\|icd"
```

If you see your driver mentioned, it's loaded!

---

## 💡 Quick Diagnosis Commands

```bash
# Is driver loading?
adb logcat -d | grep "XenoWrapper" | head -5

# Any errors?
adb logcat -d | grep -E "XenoWrapper.*[EF]/"

# How many textures decompressed?
adb logcat -d | grep "decoded.*texture" | wc -l

# What formats used?
adb logcat -d | grep "format=" | cut -d'=' -f2 | sort | uniq -c
```

---

## 📝 Example Debugging Session

```bash
# 1. Clear logs
adb logcat -c

# 2. Start watching (in terminal)
adb logcat -s "XenoWrapper:*" -v time

# 3. Launch Elden Ring in GameHub

# 4. You see:
# 21:30:01.123 I XenoWrapper: context created successfully
# 21:30:02.456 D XenoWrapper: decoded 1024x1024 texture using format 0
# 21:30:02.789 D XenoWrapper: decoded 512x512 texture using format 1
# 21:30:03.012 E XenoWrapper: unsupported format 6  ← BC7!

# 5. Conclusion:
# - BC4/BC5 working (formats 0 and 1)
# - BC7 needed (format 6 error)
# - Need to implement BC7 for full support
```

---

## 🎯 Next Steps

After collecting logs:

1. **No BC4/BC5 usage** → Implement BC6H/BC7  
2. **BC4/BC5 used but glitchy** → Fix shader bugs
3. **Crashes** → Check memory/synchronization
4. **Performance issues** → Optimize compute shaders

---

## 📞 Sharing Logs for Help

If you need help, share:
```bash
# Capture full session
adb logcat -c
# ... play game for 30 seconds ...
adb logcat -d > full_debug_log.txt
```

Then share `full_debug_log.txt` with the info:
- What game
- What you did (menu, gameplay, etc)
- What glitches you saw
- Screenshots if possible

---

## ✅ Summary

**Easiest**: Install "Logcat Reader" app, filter by "XenoWrapper"  
**Best**: Use `adb logcat -s "XenoWrapper:*"` on computer  
**For debugging**: Add more XENO_LOG statements, rebuild, test

Your driver is already logging! Just need to read it! 🚀
