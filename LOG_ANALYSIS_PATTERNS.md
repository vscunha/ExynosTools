# Log Analysis Patterns for BC4/BC5 Debugging

## Quick Reference: What Logs Mean

### 1. Success Pattern (Working Correctly)
```
I XenoWrapper: bc_emulate: Decoding texture 1024x1024 using format BC4 (id=0)
D XenoWrapper: bc_emulate: Block calculation - blocksPerRow=256, dispatch=256x256
D XenoWrapper: bc_emulate: Dispatching compute shader for 65536 blocks
I XenoWrapper: bc_emulate: ✓ Successfully decompressed 1024x1024 texture (format=0)
```
**Meaning**: BC4 texture decoded successfully. No bugs here.

---

### 2. Missing Format Pattern (BC6H/BC7 Needed)
```
E XenoWrapper: bc_emulate: Unsupported format requested: 98
E XenoWrapper: bc_emulate: Unsupported format requested: 99
```
**Meaning**: Game is using BC6H (98) or BC7 (99). You need to implement these formats.

**Format IDs**:
- `0` = BC4 (ATI1/RGTC1)
- `1` = BC5 (ATI2/RGTC2)
- `98` = BC6H (BPTC Float HDR)
- `99` = BC7 (BPTC)

---

### 3. Vulkan Error Pattern (Implementation Bug)
```
E XenoWrapper: bc_emulate: Failed to create descriptor set layout: VkResult=-4
E XenoWrapper: bc_emulate: Failed to create pipeline: VkResult=-1000012000
```
**Meaning**: Vulkan pipeline setup failed. Check shader compilation or descriptor bindings.

**Common VkResult codes**:
- `-3` = VK_ERROR_OUT_OF_HOST_MEMORY
- `-4` = VK_ERROR_OUT_OF_DEVICE_MEMORY
- `-1000012000` = VK_ERROR_INVALID_SHADER_NV

---

### 4. Dimension Bug Pattern (Math Error)
```
I XenoWrapper: bc_emulate: Decoding texture 1920x1080 using format BC4 (id=0)
D XenoWrapper: bc_emulate: Block calculation - blocksPerRow=480, dispatch=480x270
I XenoWrapper: bc_emulate: ✓ Successfully decompressed 1920x1080 texture (format=0)
```
But texture appears corrupted/shifted.

**Meaning**: Block calculation is correct (1920/4=480, 1080/4=270), but shader might have:
- Wrong texture coordinate calculation
- Incorrect block boundary handling
- Off-by-one errors in indexing

---

### 5. Interpolation Bug Pattern (Visual Artifacts)

**Symptoms in Game**:
- BC4: Grainy/blocky shadows or alpha masks
- BC5: Bumpy/incorrect normal maps (lighting looks wrong)

**Logs Show**:
```
I XenoWrapper: bc_emulate: ✓ Successfully decompressed 512x512 texture (format=0)
I XenoWrapper: bc_emulate: ✓ Successfully decompressed 1024x1024 texture (format=1)
```

**Meaning**: Decompression succeeds, but output colors are wrong. Bug is in shader interpolation formula.

**Check**:
- `bc4.comp`: `bc4_palette()` function - 6-point vs 8-point interpolation
- `bc5.comp`: Should use same logic as BC4 but for two channels

---

## Diagnostic Workflow

### Step 1: Identify Which Formats Are Used
```bash
adb logcat -s XenoWrapper:* | grep "Decoding texture"
```

**Expected Output**:
- Only `format BC4` and `format BC5` → No missing formats, bug is in implementation
- Includes `Unsupported format: 98` or `99` → Need BC6H/BC7 implementation

---

### Step 2: Check Success Rate
```bash
adb logcat -s XenoWrapper:* | grep -E "(✓ Successfully|Failed)"
```

**Healthy Output**:
```
I XenoWrapper: bc_emulate: ✓ Successfully decompressed...
I XenoWrapper: bc_emulate: ✓ Successfully decompressed...
```

**Unhealthy Output**:
```
E XenoWrapper: bc_emulate: Failed to allocate descriptor set: VkResult=-4
E XenoWrapper: bc_emulate: Failed to create pipeline: VkResult=-1000012000
```

---

### Step 3: Correlate Logs with Visual Glitches

1. **Start logging**: `adb logcat -s XenoWrapper:* > elden_ring_logs.txt`
2. **Trigger glitch**: Go to menu/area with visible glitch
3. **Stop logging**: Ctrl+C
4. **Check logs**: Look at last 50-100 lines before glitch

**Example Correlation**:
- Glitch appears on character menu
- Last 10 logs show BC5 normal map decompression
- **Conclusion**: BC5 shader has interpolation bug

---

## Common Elden Ring Texture Usage

Based on typical game texture usage:

| Scene | Likely Formats |
|-------|----------------|
| **Character menus** | BC4 (alpha masks), BC5 (normal maps), BC7 (UI textures) |
| **Intro cinematics** | BC7 (color), BC6H (HDR lighting), BC5 (normals) |
| **Gameplay terrain** | BC4 (height), BC5 (normals), BC7 (albedo) |
| **Skybox** | BC6H (HDR sky), BC7 (clouds) |

---

## Quick Diagnosis Table

| Symptom | Likely Cause | Action |
|---------|--------------|--------|
| **Black textures** | Missing BC6H/BC7 | Implement formats |
| **Blocky/pixelated textures** | BC4/BC5 interpolation bug | Fix shader |
| **Shifted/misaligned textures** | Block calculation error | Fix dispatch math |
| **Crashes on load** | Vulkan pipeline error | Check VkResult codes |
| **Random corruption** | Out-of-bounds access | Add bounds checking |
| **Wrong colors** | Channel swizzling error | Check R/G/B/A order |

---

## Advanced: Dumping Specific Textures

If you want to save a texture to debug offline:

```c
// Add to xeno_bc_decode_image() after successful decompression
#ifdef DEBUG_DUMP_TEXTURES
FILE *fp = fopen("/sdcard/texture_dump.bin", "wb");
fwrite(/* texture data */, 1, /* size */, fp);
fclose(fp);
XENO_LOGI("bc_emulate: Dumped texture to /sdcard/texture_dump.bin");
#endif
```

Then analyze with image tools like GIMP or ImageMagick.

---

## Example Debugging Session

**Scenario**: Elden Ring character menu shows glitchy textures

**Step 1 - Capture logs**:
```bash
adb logcat -s XenoWrapper:* > menu_glitch.txt
```

**Step 2 - Open menu, then check logs**:
```bash
tail -n 50 menu_glitch.txt
```

**Output**:
```
I XenoWrapper: bc_emulate: Decoding texture 512x512 using format BC5 (id=1)
I XenoWrapper: bc_emulate: ✓ Successfully decompressed 512x512 texture (format=1)
I XenoWrapper: bc_emulate: Decoding texture 1024x1024 using format BC5 (id=1)
I XenoWrapper: bc_emulate: ✓ Successfully decompressed 1024x1024 texture (format=1)
E XenoWrapper: bc_emulate: Unsupported format requested: 99
E XenoWrapper: bc_emulate: Unsupported format requested: 99
```

**Analysis**:
1. BC5 textures decode successfully → BC5 shader probably OK
2. Multiple "Unsupported format: 99" errors → BC7 is missing
3. **Conclusion**: Glitches are from missing BC7, not BC4/BC5 bugs

**Action**: Implement BC7 support

---

**Step 3 - Test specific area**:

Go to intro cinematic, capture logs:

```
I XenoWrapper: bc_emulate: Decoding texture 1920x1080 using format BC4 (id=0)
I XenoWrapper: bc_emulate: ✓ Successfully decompressed 1920x1080 texture (format=0)
E XenoWrapper: bc_emulate: Unsupported format requested: 98
E XenoWrapper: bc_emulate: Unsupported format requested: 98
E XenoWrapper: bc_emulate: Unsupported format requested: 99
```

**Analysis**:
- BC4 works
- BC6H (98) missing → HDR lighting glitches
- BC7 (99) missing → Color textures glitches

**Priority**: Implement BC7 first (more common), then BC6H

---

## Next Steps After Diagnosis

### If BC4/BC5 Have Bugs:
1. Read BC specification: https://www.khronos.org/registry/DataFormat/specs/1.3/dataformat.1.3.html
2. Review `assets/shaders/src/bc4.comp` and `bc5.comp`
3. Focus on interpolation formulas in `bc4_palette()` and `bc5_palette()`
4. Test with known-good reference images

### If BC6H/BC7 Are Needed:
1. Prioritize BC7 (more common in games)
2. BC7 has 8 modes - start with mode 6 (most common)
3. BC6H is simpler but less critical
4. Reference implementation: https://github.com/microsoft/DirectXTex

---

## Summary

**Key Insight**: Logs will tell you exactly what the problem is:
- **"Unsupported format"** → Missing BC6H/BC7
- **"Successfully decompressed" but still glitchy** → BC4/BC5 shader bug
- **Vulkan errors** → Pipeline/descriptor setup issue
- **No logs at all** → Driver not loading or logging disabled

Good luck debugging! Share your logs and I can help interpret them.
