#!/bin/bash

# Script to patch headers to use quoted includes instead of angled

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

# Find the Headers folder inside the XCFramework regardless of architecture naming
FRAMEWORK_DIR="$(find "$PROJECT_ROOT/Binaries/TesseractCore.xcframework" -path "*/TesseractCore.framework/Headers" -print -quit)"

echo "Patching TesseractCore headers to use quoted includes..."

if [ -z "$FRAMEWORK_DIR" ] || [ ! -d "$FRAMEWORK_DIR" ]; then
    echo "Could not find TesseractCore headers directory; skipping patch."
    exit 0
fi

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
