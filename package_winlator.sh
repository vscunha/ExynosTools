#!/bin/bash
set -e

# Package for Winlator/GameHub in the correct format
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="${SCRIPT_DIR}/build"
PACKAGE_NAME="exynostools-winlator-v1.3.0-dev"
TEMP_DIR="/tmp/${PACKAGE_NAME}"

echo "=== ExynosTools Winlator Package Builder ==="
echo ""

# Check if library exists
if [ ! -f "${BUILD_DIR}/libxeno_wrapper.so" ]; then
    echo "Error: libxeno_wrapper.so not found in build/"
    echo "Please run: cd build && cmake .. && make"
    exit 1
fi

# Clean and create temp directory
rm -rf "${TEMP_DIR}"
mkdir -p "${TEMP_DIR}/libs/arm64-v8a"

echo "Copying files..."
# Copy the library
cp "${BUILD_DIR}/libxeno_wrapper.so" "${TEMP_DIR}/libs/arm64-v8a/"

# Copy metadata files
cp "${SCRIPT_DIR}/xclipse_tools_icd.conf" "${TEMP_DIR}/"
cp "${SCRIPT_DIR}/meta.json" "${TEMP_DIR}/"
cp "${SCRIPT_DIR}/README.txt" "${TEMP_DIR}/"

echo "Stripping debug symbols..."
aarch64-linux-gnu-strip "${TEMP_DIR}/libs/arm64-v8a/libxeno_wrapper.so" 2>/dev/null || \
    strip "${TEMP_DIR}/libs/arm64-v8a/libxeno_wrapper.so" 2>/dev/null || \
    echo "Warning: Could not strip binary (strip command not found)"

# Create the zip (files at root, not in subdirectory)
echo "Creating package..."
cd "${TEMP_DIR}"
zip -q -r "${PACKAGE_NAME}.zip" ./*

# Move to build artifacts
mkdir -p "${SCRIPT_DIR}/artifacts"
mv "${PACKAGE_NAME}.zip" "${SCRIPT_DIR}/artifacts/"

# Cleanup
rm -rf "${TEMP_DIR}"

echo ""
echo "=== Package Created Successfully ==="
echo "Location: ${SCRIPT_DIR}/artifacts/${PACKAGE_NAME}.zip"
echo ""
echo "Installation:"
echo "1. Transfer artifacts/${PACKAGE_NAME}.zip to your Android device"
echo "2. In Winlator: Settings → AdrenoTools GPU Drivers → Install"
echo "3. Select the zip file and enable the driver"
echo "4. Restart container"
echo ""
ls -lh "${SCRIPT_DIR}/artifacts/${PACKAGE_NAME}.zip"
