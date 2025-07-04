#!/bin/bash

# Script to create XCFrameworks with proper header structure

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"
LIBS_DIR="$PROJECT_ROOT/Libraries/tesseract"
OUTPUT_DIR="$PROJECT_ROOT/Binaries"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Creating XCFrameworks with proper header structure${NC}"

# Clean existing
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

# Function to create XCFramework with proper headers
create_xcframework() {
    local NAME=$1
    local LIB_NAME=$2
    
    echo -e "${YELLOW}Creating $NAME.xcframework${NC}"
    
    # Create temporary directory for framework
    local TEMP_DIR="$PROJECT_ROOT/build/temp_framework"
    rm -rf "$TEMP_DIR"
    mkdir -p "$TEMP_DIR"
    
    # Create framework structure
    local FRAMEWORK_DIR="$TEMP_DIR/$NAME.framework"
    mkdir -p "$FRAMEWORK_DIR/Headers"
    mkdir -p "$FRAMEWORK_DIR/Modules"
    
    # Copy library
    cp "$LIBS_DIR/lib/$LIB_NAME" "$FRAMEWORK_DIR/$NAME"
    
    # Copy headers with proper structure
    if [ "$NAME" == "Leptonica" ]; then
        # For Leptonica, copy directly
        cp -r "$LIBS_DIR/include/leptonica/"* "$FRAMEWORK_DIR/Headers/"
        
        # Create umbrella header
        cat > "$FRAMEWORK_DIR/Headers/$NAME.h" << 'EOF'
#ifndef LEPTONICA_H
#define LEPTONICA_H

#include "allheaders.h"

#endif
EOF
    elif [ "$NAME" == "TesseractCore" ]; then
        # For Tesseract, maintain the tesseract/ subdirectory structure
        mkdir -p "$FRAMEWORK_DIR/Headers/tesseract"
        cp -r "$LIBS_DIR/include/tesseract/"* "$FRAMEWORK_DIR/Headers/tesseract/"
        
        # Also copy to root for backward compatibility
        cp -r "$LIBS_DIR/include/tesseract/"* "$FRAMEWORK_DIR/Headers/"
        
        # Create umbrella header
        cat > "$FRAMEWORK_DIR/Headers/$NAME.h" << 'EOF'
#ifndef TESSERACTCORE_H
#define TESSERACTCORE_H

// Include with tesseract/ prefix for internal includes
#include "tesseract/baseapi.h"
#include "tesseract/capi.h"
#include "tesseract/ocrclass.h"
#include "tesseract/publictypes.h"
#include "tesseract/renderer.h"
#include "tesseract/resultiterator.h"
#include "tesseract/pageiterator.h"
#include "tesseract/ltrresultiterator.h"
#include "tesseract/unichar.h"
#include "tesseract/osdetect.h"
#include "tesseract/version.h"

// Also make available without prefix
#include "baseapi.h"
#include "capi.h"

#endif
EOF
    fi
    
    # Create module map
    if [ "$NAME" == "Leptonica" ]; then
        cat > "$FRAMEWORK_DIR/Modules/module.modulemap" << EOF
framework module $NAME {
    umbrella header "$NAME.h"
    export *
    module * { export * }
    
    link "leptonica"
}
EOF
    elif [ "$NAME" == "TesseractCore" ]; then
        cat > "$FRAMEWORK_DIR/Modules/module.modulemap" << EOF
framework module $NAME {
    umbrella header "$NAME.h"
    
    module tesseract {
        header "tesseract/baseapi.h"
        header "tesseract/capi.h"
        header "tesseract/version.h"
        export *
    }
    
    export *
    module * { export * }
    
    link "tesseract"
}
EOF
    fi
    
    # Create Info.plist
    cat > "$FRAMEWORK_DIR/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>$NAME</string>
    <key>CFBundleIdentifier</key>
    <string>com.tesseractswift.$NAME</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>$NAME</string>
    <key>CFBundlePackageType</key>
    <string>FMWK</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>MinimumOSVersion</key>
    <string>13.0</string>
</dict>
</plist>
EOF
    
    # Create XCFramework
    xcodebuild -create-xcframework \
        -framework "$FRAMEWORK_DIR" \
        -output "$OUTPUT_DIR/$NAME.xcframework"
    
    # Clean up
    rm -rf "$TEMP_DIR"
    
    echo -e "${GREEN}Created $NAME.xcframework${NC}"
}

# Create XCFrameworks
create_xcframework "Leptonica" "libleptonica.a"
create_xcframework "TesseractCore" "libtesseract.a"

echo -e "${GREEN}XCFrameworks created successfully!${NC}"