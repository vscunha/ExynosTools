ExynosTools Custom Build v1.3.0-dev

This release includes BC4/BC5 texture decompression via compute shaders for Xclipse GPUs.

Installation for Winlator:
1. Transfer this zip to your Android device
2. Open Winlator → Settings → AdrenoTools GPU Drivers
3. Click "Install" → Select this zip file
4. Enable "ExynosTools Custom Build" from the driver list
5. Restart the container
6. Games requiring BC4/BC5 textures should now work!

Installation for GameHub:
1. Copy to your device
2. Settings → Graphics → Custom Vulkan Driver
3. Select this zip file
4. Enable the driver

Technical Details:
- BC4 (ATI1/RGTC1) support via compute shader decompression
- BC5 (ATI2/RGTC2) support via compute shader decompression
- Vulkan ICD driver wrapper for transparent integration
- Compatible with Xclipse 920/930/940 GPUs

For issues or updates, visit: https://github.com/WearyConcern1165/ExynosTools
