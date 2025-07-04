#!/bin/bash

# Script to patch headers to use quoted includes instead of angled

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"
FRAMEWORK_DIR="$PROJECT_ROOT/Binaries/TesseractCore.xcframework/macos-arm64/TesseractCore.framework/Headers"

echo "Patching TesseractCore headers to use quoted includes..."

# Patch baseapi.h
if [ -f "$FRAMEWORK_DIR/baseapi.h" ]; then
    sed -i '' 's/#include <tesseract\/\([^>]*\)>/#include "\1"/g' "$FRAMEWORK_DIR/baseapi.h"
    sed -i '' 's/#include <leptonica\/\([^>]*\)>/#include "\1"/g' "$FRAMEWORK_DIR/baseapi.h"
fi

# Patch all headers in tesseract subdirectory
if [ -d "$FRAMEWORK_DIR/tesseract" ]; then
    find "$FRAMEWORK_DIR/tesseract" -name "*.h" -type f | while read -r file; do
        sed -i '' 's/#include <tesseract\/\([^>]*\)>/#include "\1"/g' "$file"
        sed -i '' 's/#include <leptonica\/\([^>]*\)>/#include "\1"/g' "$file"
    done
fi

# Also patch the main directory headers
find "$FRAMEWORK_DIR" -maxdepth 1 -name "*.h" -type f | while read -r file; do
    sed -i '' 's/#include <tesseract\/\([^>]*\)>/#include "\1"/g' "$file"
    sed -i '' 's/#include <leptonica\/\([^>]*\)>/#include "\1"/g' "$file"
done

echo "Headers patched successfully!"