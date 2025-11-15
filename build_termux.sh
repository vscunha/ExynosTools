#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "🔧 ExynosTools - Termux Build for GameHub"

# Install dependencies if needed
if ! command -v clang &> /dev/null; then
    echo "📦 Installing clang..."
    pkg install -y clang binutils
fi

# Compile
echo "🔨 Compiling libxeno_wrapper.so for Android..."

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
    src/vk_funcs.c \
    -lm -ldl -llog

# Verify
if [ ! -f "libxeno_wrapper.so" ]; then
    echo "❌ Build failed!"
    exit 1
fi

SIZE=$(stat -c%s "libxeno_wrapper.so")
echo ""
echo "✅ Binary created: libxeno_wrapper.so ($SIZE bytes)"

# Check dependencies
echo ""
echo "🔍 Checking dependencies:"
readelf -d libxeno_wrapper.so | grep NEEDED | grep -v "File:" || true

echo ""
echo "✅ Build complete!"
echo ""
echo "📋 To install in GameHub:"
echo "   cp libxeno_wrapper.so /data/data/gamehub.lite/files/usr/lib/"
echo ""
echo "📋 Or create ZIP package:"
echo "   mkdir -p package/usr/lib"
echo "   cp libxeno_wrapper.so package/usr/lib/"
echo "   cd package && zip -r ../exynostools-gamehub.zip ."
