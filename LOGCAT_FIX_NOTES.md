# Logcat Fix - Runtime Android Detection

## Problem
The original logging system required compile-time `__ANDROID__` definition, but we're cross-compiling on Linux for Android ARM64. This meant logs would use `fprintf(stderr)` which doesn't show up in Android logcat.

## Solution
**Runtime Detection** - The library now detects if it's running on Android by attempting to load `liblog.so` at runtime:

```c
g_liblog = dlopen("liblog.so", RTLD_NOW);
if (g_liblog) {
    android_log_func = dlsym(g_liblog, "__android_log_print");
    if (android_log_func) {
        g_use_android_log = 1;  // Success! Use Android logcat
    }
}
```

## Environment Variables - ANSWER TO YOUR QUESTION

### ✅ **LOGGING IS ENABLED BY DEFAULT!** 

**You don't need to set any environment variables for basic logging.**

Just install the driver and run:
```bash
adb logcat -s XenoWrapper:*
```

### Optional Environment Variables:

#### `EXYNOSTOOLS_DEBUG=1`
Enables verbose debug logs (`XENO_LOGD` macros). 

**Without this:** Only Info/Warning/Error logs show  
**With this:** Also shows Debug logs with detailed block calculations

**How to set in Winlator:**
1. Go to Container settings
2. Add environment variable: `EXYNOSTOOLS_DEBUG=1`
3. Restart container

#### `EXYNOSTOOLS_LOG_PATH=/path/to/file.txt`
Redirects logs to a file instead of logcat.

**Example:**
```bash
export EXYNOSTOOLS_LOG_PATH=/sdcard/exynostools_debug.log
```

## How It Works

### On Android (GameHub/Winlator):
1. Library loads → calls `xeno_logging_init()`
2. Tries to open `liblog.so` (Android's logging library)
3. ✅ **Success** → Uses `__android_log_print()` 
4. **All logs go to Android logcat automatically**
5. Filter with: `adb logcat -s XenoWrapper:*`

### On Linux (Development):
1. Library loads → calls `xeno_logging_init()`
2. Tries to open `liblog.so`
3. ❌ **Fails** (doesn't exist on Linux)
4. Falls back to `fprintf(stderr)`
5. Logs appear in terminal

## What You'll See

### Basic Logs (Default - No Environment Variables):
```
I XenoWrapper: ExynosTools logging initialized (Android logcat mode)
I XenoWrapper: bc_emulate: Initializing BC texture decompression context
I XenoWrapper: bc_emulate: Creating BC4 shader module
I XenoWrapper: bc_emulate: ✓ BC4 pipeline created successfully
I XenoWrapper: bc_emulate: Creating BC5 shader module
I XenoWrapper: bc_emulate: ✓ BC5 pipeline created successfully
I XenoWrapper: bc_emulate: context created successfully with BC4/BC5 support
I XenoWrapper: bc_emulate: Decoding texture 1024x1024 using format BC4 (id=0)
I XenoWrapper: bc_emulate: ✓ Successfully decompressed 1024x1024 texture (format=0)
E XenoWrapper: bc_emulate: Unsupported format requested: 99
```

### Debug Logs (With EXYNOSTOOLS_DEBUG=1):
```
I XenoWrapper: ExynosTools logging initialized (Android logcat mode)
I XenoWrapper: bc_emulate: Initializing BC texture decompression context
D XenoWrapper: bc_emulate: Shader module BC4 size: 1234 bytes
I XenoWrapper: bc_emulate: Creating BC4 shader module
D XenoWrapper: bc_emulate: Creating compute pipeline for BC4
I XenoWrapper: bc_emulate: ✓ BC4 pipeline created successfully
I XenoWrapper: bc_emulate: Decoding texture 1024x1024 using format BC4 (id=0)
D XenoWrapper: bc_emulate: Block calculation - blocksPerRow=256, dispatch=256x256
D XenoWrapper: bc_emulate: Dispatching compute shader for 65536 blocks
I XenoWrapper: bc_emulate: ✓ Successfully decompressed 1024x1024 texture (format=0)
```

## Testing the New Build

### 1. Install
```bash
# Transfer to Android
adb push artifacts/exynostools-winlator-v1.3.0-dev.zip /sdcard/

# Install in GameHub/Winlator: Settings → GPU Drivers → Install
```

### 2. Clear logs and test
```bash
adb logcat -c
# Launch game in GameHub
adb logcat -s XenoWrapper:*
```

### 3. First line should be:
```
I XenoWrapper: ExynosTools logging initialized (Android logcat mode)
```

**If you see that → logging works! 🎉**

## Troubleshooting

| Problem | Solution |
|---------|----------|
| No logs at all | Driver not loading - check GameHub settings |
| Shows "(stderr mode)" instead of "(Android logcat mode)" | Running on Linux (normal for development) |
| Want more detailed logs | Set `EXYNOSTOOLS_DEBUG=1` in Winlator |
| Want to save logs to file | Run `adb logcat -s XenoWrapper:* > log.txt` |

## Summary

✅ **Default: Logging enabled, no setup needed**  
✅ **Just run:** `adb logcat -s XenoWrapper:*`  
✅ **Optional:** Set `EXYNOSTOOLS_DEBUG=1` for verbose output  
✅ **Works:** Runtime detection, same binary for Android and Linux  

The new package at `artifacts/exynostools-winlator-v1.3.0-dev.zip` has all the logging fixes!

## Problem Found

Your `full_debug_log.txt` showed **ZERO logs from ExynosTools**, only Termux/Android system logs. This was because:

1. **Wrong logging backend**: The code was using `fprintf()` to write to files/stderr, which doesn't appear in Android `logcat`
2. **Wrong log tag**: Was using `[ExynosTools]` instead of `XenoWrapper`
3. **Missing Android integration**: Need `__android_log_print()` for proper Android logging

## Changes Made

### 1. Updated `src/logging.h`
```c
#ifdef __ANDROID__
    #include <android/log.h>
    #define XENO_LOGI(fmt, ...) __android_log_print(ANDROID_LOG_INFO, "XenoWrapper", fmt, ##__VA_ARGS__)
    #define XENO_LOGW(fmt, ...) __android_log_print(ANDROID_LOG_WARN, "XenoWrapper", fmt, ##__VA_ARGS__)
    #define XENO_LOGE(fmt, ...) __android_log_print(ANDROID_LOG_ERROR, "XenoWrapper", fmt, ##__VA_ARGS__)
    #define XENO_LOGD(fmt, ...) __android_log_print(ANDROID_LOG_DEBUG, "XenoWrapper", fmt, ##__VA_ARGS__)
#else
    // Fallback to fprintf for non-Android builds
    // ...
#endif
```

**Changes**:
- ✅ Uses Android's native logging system (`__android_log_print`)
- ✅ Tag is now `XenoWrapper` (matches `adb logcat -s XenoWrapper:*`)
- ✅ Compiles on both Linux (for testing) and Android (for GameHub)

### 2. Updated `CMakeLists.txt`
```cmake
if(ANDROID)
    target_link_libraries(xeno_wrapper PRIVATE dl Threads::Threads log)
else()
    target_link_libraries(xeno_wrapper PRIVATE dl Threads::Threads)
endif()
```

**Changes**:
- ✅ Links `-llog` only on Android (required for `__android_log_print`)
- ✅ Regular Linux builds still work without Android libraries

## New Package

**File**: `exynostools-winlator-v1.3.0-LOGCAT_FIXED.zip`

This package now has **Android logcat integration enabled**.

## How to Test

### 1. Install the New Package in GameHub
1. Copy `exynostools-winlator-v1.3.0-LOGCAT_FIXED.zip` to your phone
2. Install it in GameHub as a custom driver
3. Select Elden Ring

### 2. Capture Logs
On your computer with ADB:
```bash
adb logcat -s XenoWrapper:* > elden_ring_proper_logs.txt
```

Or on phone with Logcat Reader app, filter for `XenoWrapper`.

### 3. Start Elden Ring
The moment the driver loads, you should see:
```
I XenoWrapper: === XenoTools Vulkan Wrapper Initializing ===
I XenoWrapper: Detected GPU: Mali-G715-Immortalis MC10 (Xclipse 920)
I XenoWrapper: bc_emulate: Creating BC context...
I XenoWrapper: bc_emulate: ✓ Created BC4 pipeline successfully
I XenoWrapper: bc_emulate: ✓ Created BC5 pipeline successfully
I XenoWrapper: bc_emulate: context created successfully with BC4/BC5 support
```

### 4. During Gameplay
You'll see logs like:
```
I XenoWrapper: bc_emulate: Decoding texture 1024x1024 using format BC4 (id=0)
D XenoWrapper: bc_emulate: Block calculation - blocksPerRow=256, dispatch=256x256
D XenoWrapper: bc_emulate: Dispatching compute shader for 65536 blocks
I XenoWrapper: bc_emulate: ✓ Successfully decompressed 1024x1024 texture (format=0)
```

**OR** if BC6H/BC7 is needed:
```
E XenoWrapper: bc_emulate: Unsupported format requested: 99
```

## What This Tells Us

### If You See Lots of "Successfully decompressed" Logs But Still Have Glitches:
→ **BC4/BC5 implementation has bugs** (interpolation formula wrong)
→ Fix the shaders in `assets/shaders/src/bc4.comp` and `bc5.comp`

### If You See "Unsupported format: 98" or "99":
→ **BC6H (98) or BC7 (99) is missing**
→ Need to implement these formats (BC7 is very complex - 8 compression modes)

### If You See NO Logs At All:
→ **Driver is not loading** in GameHub
→ Check the ICD manifest path or GameHub driver selection

## Next Steps

1. **Test this new build** and share the logs
2. Based on what we see:
   - If lots of BC4/BC5 logs → debug shader interpolation
   - If "unsupported format" errors → implement BC6H/BC7
   - If no logs → driver loading issue

Good luck! The logging should now work properly in logcat. 🔧✅
