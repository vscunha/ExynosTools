#!/system/bin/sh
# ExynosTools v1.3.0 - Winlator Loader Script
# This script sets up the Vulkan layer for use in Winlator/GameHub

# Get the driver directory
DRIVER_DIR="$(dirname "$0")"
DRIVER_LIB="$DRIVER_DIR/usr/lib"
DRIVER_CONF="$DRIVER_DIR/etc/exynostools"

# Set up library paths
export LD_LIBRARY_PATH="$DRIVER_LIB:$LD_LIBRARY_PATH"

# Enable ExynosTools layer
export LD_PRELOAD="$DRIVER_LIB/libxeno_wrapper.so:$LD_PRELOAD"

# Optional: Enable the Vulkan layer via standard mechanism
export VK_LAYER_PATH="$DRIVER_DIR/usr/share/vulkan/implicit_layer.d:$VK_LAYER_PATH"

# Configuration path
export EXYNOSTOOLS_CONFIG_PATH="$DRIVER_CONF"

# Enable by default (can be overridden)
export ENABLE_EXYNOSTOOLS="${ENABLE_EXYNOSTOOLS:-1}"

# Optional: Enable HUD for testing
# export EXYNOSTOOLS_HUD=1

echo "ExynosTools v1.3.0 loaded"
echo "Library: $DRIVER_LIB/libxeno_wrapper.so"
echo "Config: $DRIVER_CONF"
