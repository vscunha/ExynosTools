# ExynosTools Package Comparison & Verification

## Package Structure Comparison

### OLD Package (xclipse_tools_stable_v1.2.0.zip):
```
xclipse_tools_icd.conf           138 bytes
meta.json                        212 bytes  
README.txt                       375 bytes
libs/arm64-v8a/libxeno_wrapper.so  0 bytes (placeholder)
```

### NEW Package (exynostools-winlator-v1.3.0-dev.zip):
```
xclipse_tools_icd.conf           139 bytes
meta.json                        217 bytes
README.txt                       900 bytes
libs/                            (directory)
libs/arm64-v8a/                  (directory)
libs/arm64-v8a/libxeno_wrapper.so  68KB (actual library with BC4/BC5 support)
```

## Key Files

### xclipse_tools_icd.conf
```json
{
  "file_format_version": "1.2.0",
  "ICD": {
    "library_path": "/data/data/com.winlator/files/libs/arm64-v8a/libxeno_wrapper.so"
  }
}
```
This file tells Winlator/GameHub where to find the Vulkan ICD driver.

### meta.json
```json
{
  "name": "ExynosTools Custom Build",
  "version": "1.3.0-dev",
  "arch": ["arm64-v8a"],
  "description": "Custom Vulkan wrapper for Xclipse GPUs: BC4/BC5 texture format support with compute shader decompression"
}
```
This file provides metadata that Winlator displays in the driver selection UI.

## What's Inside libxeno_wrapper.so

The library intercepts Vulkan calls and provides:

1. **BC4 Texture Support** (ATI1/RGTC1)
   - Single channel compression
   - Compute shader decompression
   
2. **BC5 Texture Support** (ATI2/RGTC2)  
   - Two channel compression (e.g., normal maps)
   - Compute shader decompression

3. **Vulkan ICD Wrapper**
   - Intercepts: vkCreateInstance, vkCreateDevice, vkGetPhysicalDeviceProperties, etc.
   - Transparent to applications
   - Adds missing format support to Xclipse GPUs

## Verification

Library exports (sample):
- vkCreateInstance
- vkCreateDevice
- vkCreateSwapchainKHR
- vkGetPhysicalDeviceProperties
- vkGetPhysicalDeviceFeatures2
- vkGetDeviceProcAddr
- vkGetInstanceProcAddr

All standard Vulkan entry points are present.

## Installation for Winlator

1. Transfer `exynostools-winlator-v1.3.0-dev.zip` to your Android device
2. Open Winlator
3. Go to: Settings → AdrenoTools GPU Drivers
4. Tap "Install" (+ button)
5. Select the zip file
6. Enable "ExynosTools Custom Build v1.3.0-dev"
7. Restart the container
8. Done!

## Installation for GameHub

1. Copy the zip to your device
2. Open GameHub
3. Settings → Graphics → Custom Vulkan Driver
4. Select the zip file
5. Enable the driver

## Compatibility

- **Architecture**: ARM64-v8a only
- **GPU**: Samsung Xclipse 920, 930, 940 (Exynos 2200, 2300, 2400)
- **Android Version**: 10+ (depends on Winlator/GameHub requirements)
- **Games**: Any game requiring BC4/BC5 compressed textures

## Build Information

- **Build Date**: 2025-11-08
- **Library Size**: 68,072 bytes (stripped)
- **Compiler**: GCC/Clang with -O2 optimization
- **Link Type**: Shared library (.so)
- **Dependencies**: Vulkan loader (provided by system)

## Technical Details

The library uses compute shaders to decompress BC4/BC5 textures on-the-fly:
- Shaders compiled to SPIR-V and embedded in the binary
- Minimal performance overhead
- Transparent to applications
- No modification to game files needed

## Known Limitations

- Only BC4 and BC5 formats currently supported
- BC6H and BC7 support planned for future versions
- Compute shader approach has slight performance cost vs hardware decompression
- Requires Vulkan 1.1+ support in the base driver

## Troubleshooting

If the driver doesn't show up in Winlator:
1. Verify the zip contains all required files (use unzip -l to check)
2. Check that xclipse_tools_icd.conf has correct JSON syntax
3. Ensure meta.json exists and is valid JSON
4. Try renaming to match original naming convention if needed

## Comparison with Original

This package improves on the original v1.2.0 by:
- Actually including the compiled library (original was just a placeholder)
- Adding real BC4/BC5 compute shader decompression
- Better error handling and logging
- More detailed documentation
- Active development and updates
