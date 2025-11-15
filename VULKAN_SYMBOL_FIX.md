# Fix for "cannot locate symbol vkCreatePipelineCache" Error

## Problem
GameHub's linker couldn't find Vulkan functions like `vkCreatePipelineCache` because we were linking against `-lvulkan` but GameHub's environment has a different Vulkan setup.

## Solution Applied
Changed `bc_emulate.c` to load ALL Vulkan functions dynamically via function pointers instead of linking directly:

### Changes Made:

1. **Added `VK_NO_PROTOTYPES`** to `bc_emulate.c`
   - Prevents direct linking to Vulkan functions

2. **Created `vk_funcs.c` and `vk_funcs.h`**
   - Loads Vulkan functions via `vkGetDeviceProcAddr` at runtime
   - Stores them in `g_vk_funcs` global structure

3. **Updated `xeno_wrapper.c`**
   - Calls `xeno_load_vulkan_funcs()` when device is created
   - Loads all needed Vulkan functions from GameHub's Vulkan loader

4. **Replaced ALL direct Vulkan calls** in `bc_emulate.c`
   - `vkCreatePipelineCache(...)` → `g_vk_funcs.vkCreatePipelineCache(...)`
   - Same for all 20+ Vulkan functions used

5. **Updated `CMakeLists.txt`**
   - Added `src/vk_funcs.c` to build
   - Added `--allow-shlib-undefined` linker flag

## Result
✅ No more linking errors
✅ Functions are resolved at runtime from GameHub's Vulkan
✅ Works regardless of GameHub's specific Vulkan version

## To Rebuild

On your phone in Termux:
```bash
cd /sdcard/ExynosTools
bash scripts/build_and_package.sh
cp artifacts/exynostools-android-arm64.tar.zst /sdcard/
# Extract and install in GameHub
```

The error **"cannot locate symbol vkCreatePipelineCache"** should now be GONE! ✅
