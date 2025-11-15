````markdown
# 🎮 ExynosTools v1.3.0 - Quick Start for Winlator/GameHub

## 🔍 LOGGING - Do I Need Environment Variables?

### ✅ **NO! Logging is ENABLED BY DEFAULT**

Just install the driver and view logs:
```bash
adb logcat -s XenoWrapper:*
```

**You'll automatically see:**
- Driver initialization messages
- BC4/BC5 texture decompression events  
- Format support (which formats work, which are missing)
- Errors and warnings

### Optional: Want MORE detailed logs?

Set this in Winlator container settings:
```bash
EXYNOSTOOLS_DEBUG=1
```

**This enables:**
- Verbose debug output
- Block calculation details
- Shader compilation info
- Performance metrics

**See [`LOGCAT_FIX_NOTES.md`](LOGCAT_FIX_NOTES.md) for full details.**

---

## ✅ Your package is NOW ready for Winlator and GameHub!

### What's included in your package:

```
exynostools-android-arm64.tar.zst/
├── usr/
│   ├── lib/
│   │   └── libxeno_wrapper.so          ← Main Vulkan wrapper library (75KB)
│   └── share/
│       ├── meta.json                    ← Driver metadata
│       └── vulkan/
│           └── implicit_layer.d/
│               └── VkLayer_exynostools.json  ← Vulkan layer manifest
├── etc/
│   └── exynostools/
│       ├── performance_mode.conf        ← Global settings
│       └── profiles/                    ← Per-app configs
│           ├── dxvk.conf
│           ├── vkd3d.conf
│           └── example_game.conf
├── winlator.conf                        ← Winlator integration config
└── exynostools-loader.sh               ← Loader script
```

---

## 📱 Installation Options

### Option A: Winlator Custom Driver (EASIEST)

1. **Copy the package to your device**:
   ```bash
   # Using adb
   adb push build/artifacts/exynostools-android-arm64.tar.zst /sdcard/Download/
   
   # Or copy manually to:
   # /sdcard/Download/ or /sdcard/Android/data/com.winlator/files/drivers/
   ```

2. **Install in Winlator**:
   - Open **Winlator** app
   - Go to **Settings** → **Advanced** → **Custom Drivers**
   - Tap **"Install from file"**
   - Select `exynostools-android-arm64.tar.zst`
   - Winlator will extract it automatically

3. **Enable for your container**:
   - Open your Wine container (or create new one)
   - Go to **Environment Variables**
   - Add: `LD_PRELOAD=libxeno_wrapper.so`
   - Add: `ENABLE_EXYNOSTOOLS=1`
   - Save and restart container

4. **Test it**:
   - Launch a game
   - Check logcat: `adb logcat | grep -i exynos`
   - You should see: `"ExynosTools v1.3.0 loaded"`

---

### Option B: Manual Installation (Full Control)

1. **Extract the package**:
   ```bash
   cd /sdcard/Android/data/com.winlator/files/
   tar --zstd -xf /sdcard/Download/exynostools-android-arm64.tar.zst
   ```

2. **Set up environment in Winlator**:
   
   In your container's startup script or environment variables:
   ```bash
   export LD_LIBRARY_PATH=/data/data/com.winlator/files/usr/lib:$LD_LIBRARY_PATH
   export LD_PRELOAD=/data/data/com.winlator/files/usr/lib/libxeno_wrapper.so:$LD_PRELOAD
   export ENABLE_EXYNOSTOOLS=1
   export VK_LAYER_PATH=/data/data/com.winlator/files/usr/share/vulkan/implicit_layer.d:$VK_LAYER_PATH
   ```

3. **Optional: Enable HUD**:
   ```bash
   export EXYNOSTOOLS_HUD=1  # Shows FPS overlay
   ```

---

### Option C: GameHub Installation

1. **Copy and extract**:
   ```bash
   cd /sdcard/Android/data/com.github.gamehub/files/
   tar --zstd -xf /path/to/exynostools-android-arm64.tar.zst
   ```

2. **Configure GameHub**:
   - Open GameHub app
   - Go to your game settings
   - Add to environment variables:
     ```
     LD_PRELOAD=usr/lib/libxeno_wrapper.so
     ENABLE_EXYNOSTOOLS=1
     ```

---

## 🧪 Testing & Verification

### Check if loaded:
```bash
# Via adb
adb shell
logcat | grep -i exynostools

# Should show:
# ExynosTools v1.3.0 loaded
# Detected Xclipse GPU: Samsung Xclipse 940
# BC4/BC5 emulation ready
```

### Enable debug logging:
```bash
export EXYNOSTOOLS_LOG_LEVEL=debug
export EXYNOSTOOLS_HUD=1
```

### Test with a game:
1. Run a DXVK game (e.g., **Wine + DirectX game**)
2. Look for FPS counter (if HUD enabled)
3. Check logcat for BC texture decoding messages

---

## ⚙️ Configuration Tips

### For DXVK games:
```bash
export EXYNOSTOOLS_APP_PROFILE=dxvk
export DXVK_STATE_CACHE=1
export DXVK_ASYNC=1
```

### For VKD3D games (DirectX 12):
```bash
export EXYNOSTOOLS_APP_PROFILE=vkd3d
export VKD3D_CONFIG=dxr
```

### For low-memory devices (< 8GB RAM):
Edit `etc/exynostools/performance_mode.conf`:
```ini
[Performance]
max_threads=4
force_vram_mb=2048
```

---

## 🚨 Troubleshooting

### Library not found:
```bash
# Check if file exists
ls -la usr/lib/libxeno_wrapper.so

# Check permissions (should be 755)
chmod 755 usr/lib/libxeno_wrapper.so
```

### Not detecting Xclipse GPU:
```bash
# Force enable (for testing)
export EXYNOSTOOLS_FORCE=1
```

### Crashes or black screen:
1. Disable problematic features:
   ```bash
   export EXYNOSTOOLS_DISABLE_BCN=1
   ```
2. Check Vulkan layer order
3. Try without other Vulkan layers first

---

## 📊 What's Different from v1.2.0?

✅ **FIXED**: Library is no longer empty (was 0 bytes in v1.2.0)  
✅ **NEW**: Vulkan layer manifest for proper layer loading  
✅ **NEW**: Winlator integration config file  
✅ **NEW**: Loader script for easy setup  
✅ **IMPROVED**: Better packaging structure (tar.zst format)  
✅ **IMPROVED**: Configuration system (`.conf` files instead of `.env`)

---

## 📁 File Locations Reference

| File | Purpose | Path in Winlator |
|------|---------|-----------------|
| **Library** | Main wrapper | `usr/lib/libxeno_wrapper.so` |
| **Layer manifest** | Vulkan layer definition | `usr/share/vulkan/implicit_layer.d/VkLayer_exynostools.json` |
| **Config** | Global settings | `etc/exynostools/performance_mode.conf` |
| **Profiles** | Per-app settings | `etc/exynostools/profiles/*.conf` |
| **Loader** | Helper script | `exynostools-loader.sh` |
| **Integration** | Winlator config | `winlator.conf` |

---

## 🎯 What This Does

- **Intercepts Vulkan API calls** from games/apps
- **Adds missing extensions** (descriptor indexing, robustness, etc.)
- **Emulates BC4/BC5 texture compression** using compute shaders
- **Patches GPU features** to improve compatibility
- **Monitors performance** (HUD overlay, FPS logging)
- **Per-app profiles** for game-specific optimizations

---

## ✨ You're Ready!

Your package is **fully compatible** with:
- ✅ Winlator Bionic 10.1+
- ✅ GameHub (Android Wine)
- ✅ Any Android Wine environment
- ✅ Direct LD_PRELOAD usage

**Next steps**: Install it in Winlator and test with your favorite games! 🎮

For detailed information, see `WINLATOR_INSTALL.md`.
