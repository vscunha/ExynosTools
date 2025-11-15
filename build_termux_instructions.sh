#!/bin/bash
set -e

echo "🔧 ExynosTools - Simple Android Build (for Termux execution)"
echo ""
echo "⚠️  This script should be run ON YOUR ANDROID PHONE in Termux"
echo "⚠️  NOT on this Linux PC"
echo ""
echo "Copy this script to your phone and run:"
echo ""
echo "  pkg install clang binutils"
echo "  bash build_termux.sh"
echo ""

# This is the actual build command for Termux:
cat << 'TERMUX_BUILD'
#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "🔧 ExynosTools - Termux Android Build"

# Install dependencies if needed
if ! command -v clang &> /dev/null; then
    echo "Installing clang..."
    pkg install -y clang binutils
fi

# Compile
echo "🔨 Compiling libxeno_wrapper.so..."

clang -shared -fPIC -O2 -DNDEBUG \
    -I./src \
    -o libxeno_wrapper.so \
    src/xeno_wrapper.c \
    src/bc_emulate.c \
    src/features_patch.c \
    src/detect.c \
    src/perf_conf.c \
    src/logging.c \
    src/app_profile.c \
    -lvulkan -lm -ldl -llog

# Verify
SIZE=$(stat -c%s "libxeno_wrapper.so")
echo "✅ Binary created: libxeno_wrapper.so ($SIZE bytes)"

# Check dependencies
echo "🔍 Dependencies:"
readelf -d libxeno_wrapper.so | grep NEEDED

echo ""
echo "✅ Build complete!"
echo "📦 Copy to GameHub: cp libxeno_wrapper.so /data/data/gamehub.lite/files/usr/lib/"
TERMUX_BUILD
