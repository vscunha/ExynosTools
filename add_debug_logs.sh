#!/bin/bash
# Quick script to add more debug logging to bc_emulate.c

cat << 'EOF'
=== Enhanced Logging Patch for bc_emulate.c ===

Add these log lines to help debug BC4/BC5 issues:

1. In xeno_bc_decode_image(), after format check, add:

    XENO_LOGI("bc_emulate: Decoding texture %dx%d using format %s (id=%d)",
              extent.width, extent.height, 
              format == XENO_BC4 ? "BC4" : format == XENO_BC5 ? "BC5" : "UNKNOWN",
              format);

2. After calculating blocks, add:

    XENO_LOGD("bc_emulate: Block calculation - blocksPerRow=%d, dispatch=%dx%d",
              pushConstants[2], groupsX, groupsY);

3. Before vkCmdDispatch, add:

    XENO_LOGD("bc_emulate: Dispatching compute shader for %d blocks",
              groupsX * groupsY);

4. After the post-barrier, before returning VK_SUCCESS, add:

    XENO_LOGI("bc_emulate: ✓ Successfully decompressed %dx%d texture (format=%d)",
              extent.width, extent.height, format);

5. In error cases, make sure all XENO_LOGE calls include the VkResult code:

    XENO_LOGE("bc_emulate: Failed to allocate descriptor set: VkResult=%d", result);

This will give you detailed logs showing:
- What textures are being decompressed
- Their dimensions
- Which format (BC4 or BC5)
- If decompression succeeds or fails
- Block calculations

To apply manually, edit src/bc_emulate.c and add these lines in the appropriate places.

Then rebuild:
  cd build && make && cd .. && bash package_winlator.sh

EOF
