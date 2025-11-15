# ExynosTools v1.3.0 - Winlator & GameHub Installation Guide

## 📱 What is ExynosTools?

ExynosTools is a Vulkan wrapper/layer specifically designed for Samsung Exynos devices with Xclipse GPUs (Exynos 2400, 2500, etc.). It provides:

- ✅ **BC4/BC5 Texture Compression Emulation** (via compute shaders)
- ✅ **Feature Patching** (adds missing Vulkan extensions)
- ✅ **Performance Optimizations** for Wine/DXVK/VKD3D
- ✅ **FPS HUD Overlay** (optional)
- ✅ **Per-App Configuration Profiles**

## 🎮 Compatible With

- **Winlator** (Bionic 10.1+)
- **GameHub** (Android Wine container)
- **Mobox** (experimental)
- Any Android app using Vulkan on Xclipse GPUs

## 📦 Installation Methods

### Method 1: Winlator Custom Driver (Recommended)

1. **Download** the package:
   - Get `exynostools-android-arm64.tar.zst` from releases or build it yourself

2. **Copy to Winlator drivers folder**:
   ```
   /sdcard/Android/data/com.winlator/files/drivers/exynostools-android-arm64.tar.zst
   ```

3. **Extract in Winlator**:
   - Open Winlator
   - Go to Settings → Drivers
   - Select "Install Custom Driver"
   - Choose the `exynostools-android-arm64.tar.zst` file
   - Winlator will extract it automatically

4. **Enable for a container**:
   - Open your Wine container settings
   - Go to "Advanced" → "Custom Libraries"
   - Enable "ExynosTools"
   - Restart the container

### Method 2: Manual LD_PRELOAD (Advanced)

If Winlator doesn't support custom drivers in your version:

1. Extract the package manually:
   ```bash
   cd /sdcard/Android/data/com.winlator/files/
   tar --zstd -xf exynostools-android-arm64.tar.zst -C .
   ```

2. Edit your container's startup script or add to Winlator environment variables:
   ```bash
   export LD_PRELOAD=/path/to/usr/lib/libxeno_wrapper.so:$LD_PRELOAD
   export ENABLE_EXYNOSTOOLS=1
   ```

### Method 3: GameHub Integration

1. Copy `exynostools-android-arm64.tar.zst` to GameHub's data directory:
   ```
   /sdcard/Android/data/com.github.gamehub/files/drivers/
   ```

2. Extract it:
   ```bash
   cd /sdcard/Android/data/com.github.gamehub/files/
   tar --zstd -xf drivers/exynostools-android-arm64.tar.zst
   ```

3. Configure GameHub to use the wrapper (check GameHub documentation for custom library loading)

## ⚙️ Configuration

### Basic Configuration

The default configuration should work for most games. Files are located in:
```
etc/exynostools/
├── performance_mode.conf    # Global performance settings
└── profiles/                # Per-app configurations
    ├── dxvk.conf           # DXVK-specific settings
    ├── vkd3d.conf          # VKD3D-Proton settings
    └── example_game.conf   # Example per-game profile
```

### Environment Variables

You can control ExynosTools behavior via environment variables:

```bash
# Enable/disable (default: enabled)
ENABLE_EXYNOSTOOLS=1

# Enable FPS HUD overlay
EXYNOSTOOLS_HUD=1

# Enable FPS logging to logcat
EXYNOSTOOLS_LOG_FPS=1

# Force enable on non-Xclipse GPUs (testing only)
EXYNOSTOOLS_FORCE=1

# Specify app profile
EXYNOSTOOLS_APP_PROFILE=dxvk

# Custom config path
EXYNOSTOOLS_CONFIG_PATH=/custom/path/to/config
```

### Per-App Profiles

Create custom profiles for specific games in `etc/exynostools/profiles/`:

Example `my_game.conf`:
```ini
[Features]
# Enable specific Vulkan extensions
enable_descriptor_indexing=true
enable_dynamic_rendering=true

[Performance]
# Limit worker threads (useful on low-core devices)
max_threads=4

# VRAM management
force_vram_mb=2048

[BCn]
# Enable BC4/BC5 emulation
enable_bc4=true
enable_bc5=true
```

Then load it:
```bash
export EXYNOSTOOLS_APP_PROFILE=my_game
```

## 🔍 Verifying Installation

### Check if ExynosTools is loaded:

```bash
# In Winlator terminal or via adb shell
logcat | grep -i exynostools
```

You should see:
```
ExynosTools v1.3.0 loaded
Detected Xclipse GPU: [device name]
BC4/BC5 emulation ready
```

### Test with HUD:

```bash
export EXYNOSTOOLS_HUD=1
# Run your game - you should see FPS counter in top-left corner
```

## 🛠️ Troubleshooting

### Library not loading

**Symptoms**: Game runs but ExynosTools features don't work

**Solutions**:
1. Check library path:
   ```bash
   ls -la /sdcard/Android/data/com.winlator/files/usr/lib/libxeno_wrapper.so
   ```
2. Verify LD_PRELOAD is set:
   ```bash
   echo $LD_PRELOAD
   ```
3. Check permissions (should be readable):
   ```bash
   chmod 755 /path/to/usr/lib/libxeno_wrapper.so
   ```

### BC compression not working

**Symptoms**: Textures appear corrupted or game crashes

**Solutions**:
1. Enable debug logging:
   ```bash
   export EXYNOSTOOLS_LOG_LEVEL=debug
   logcat | grep bc_emulate
   ```
2. Check if BC4/BC5 is actually being used by the game
3. Try disabling async shader compilation in DXVK

### Performance issues

**Symptoms**: Lower FPS than expected

**Solutions**:
1. Check `performance_mode.conf`:
   - Reduce `max_threads` if you have a low-core CPU
   - Adjust `force_vram_mb` to match your device RAM
2. Disable HUD when not needed (`EXYNOSTOOLS_HUD=0`)
3. Use appropriate DXVK settings (see `profiles/dxvk.conf`)

### Game-specific issues

Some games may need custom configuration:
1. Create a profile in `etc/exynostools/profiles/`
2. Disable problematic features
3. Test different DXVK/VKD3D settings

## 📋 Compatibility List

### Tested & Working

| Game/App | Status | Notes |
|----------|--------|-------|
| **Winlator DXVK** | ✅ Working | Use dxvk.conf profile |
| **Winlator VKD3D** | ✅ Working | Use vkd3d.conf profile |
| **Zink (OpenGL)** | ✅ Working | No special config needed |

### Known Issues

- **BC6H/BC7**: Not yet implemented (planned for v1.4.0)
- **High memory games**: May need VRAM limits on 6GB devices

## 🔧 Building from Source

See main README.md for build instructions. Quick start:

```bash
# Install dependencies
apt-get install cmake gcc glslc xxd

# Build
bash scripts/build_and_package.sh

# Package will be in artifacts/
```

## 📚 More Information

- **Main README**: See `README.md` for technical details
- **Changelog**: See `RELEASE_NOTES_v1.3.0.md`
- **Issues**: Check GitHub issues for known problems
- **Community**: Join Samsung Exynos gaming communities for support

## 🤝 Credits

- ExynosTools development team
- Winlator community
- DXVK and VKD3D-Proton projects
- Android Wine community

## 📄 License

See LICENSE file for details.
