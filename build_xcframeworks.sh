#!/bin/bash

# Exit immediately on error, disallow undefined variables, fail on pipe errors
set -euo pipefail

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Set script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Set output directories
OUTPUT_DIR="${SCRIPT_DIR}/output"
ARCHIVES_DIR="${OUTPUT_DIR}/archives"
XCFRAMEWORK_DIR="${OUTPUT_DIR}/xcframeworks"

# Project configuration
PROJECT_NAME="LynxPrebuild"
WORKSPACE_NAME="${PROJECT_NAME}.xcworkspace"
SCHEME_NAME="Pods-${PROJECT_NAME}"

# Build configuration (Debug or Release)
BUILD_CONFIGURATION="Release"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN} Starting Lynx XCFramework Build${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Clean previous build artifacts
echo -e "${YELLOW}1. Cleaning previous build artifacts...${NC}"
rm -rf "$OUTPUT_DIR"
rm -rf build
rm -rf DerivedData
mkdir -p "$ARCHIVES_DIR"
mkdir -p "$XCFRAMEWORK_DIR"

# Build iOS Simulator Archive
echo ""
echo -e "${YELLOW}2. Building iOS Simulator (iphonesimulator) Archive...${NC}"
echo "   Target architectures: x86_64, arm64"

if ! xcodebuild archive \
    -workspace "$WORKSPACE_NAME" \
    -scheme "$SCHEME_NAME" \
    -configuration "$BUILD_CONFIGURATION" \
    -destination "generic/platform=iOS Simulator" \
    -archivePath "${ARCHIVES_DIR}/${PROJECT_NAME}-iphonesimulator.xcarchive" \
    -sdk iphonesimulator \
    -quiet \
    SKIP_INSTALL=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES; then
    echo -e "${RED}❌ iOS Simulator Archive build failed${NC}"
    exit 1
fi
echo -e "${GREEN}✅ iOS Simulator Archive build completed${NC}"

# Build iOS Device Archive
echo ""
echo -e "${YELLOW}3. Building iOS Device (iphoneos) Archive...${NC}"
echo "   Target architecture: arm64"

if ! xcodebuild archive \
    -workspace "$WORKSPACE_NAME" \
    -scheme "$SCHEME_NAME" \
    -configuration "$BUILD_CONFIGURATION" \
    -destination "generic/platform=iOS" \
    -archivePath "${ARCHIVES_DIR}/${PROJECT_NAME}-iphoneos.xcarchive" \
    -sdk iphoneos \
    -quiet \
    SKIP_INSTALL=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES; then
    echo -e "${RED}❌ iOS Device Archive build failed${NC}"
    exit 1
fi
echo -e "${GREEN}✅ iOS Device Archive build completed${NC}"

# Find all frameworks in archives and create XCFrameworks
echo ""
echo -e "${YELLOW}4. Locating frameworks and creating XCFrameworks...${NC}"

# Counter for generated frameworks
FRAMEWORK_COUNT=0

# Find and process all frameworks from iOS Simulator Archive
while IFS= read -r -d '' SIMULATOR_FRAMEWORK_PATH; do
    FRAMEWORK_NAME=$(basename "$SIMULATOR_FRAMEWORK_PATH")
    FRAMEWORK_BASE_NAME="${FRAMEWORK_NAME%.framework}"
    
    # Find corresponding iOS Device Framework
    DEVICE_FRAMEWORK_PATH="${ARCHIVES_DIR}/${PROJECT_NAME}-iphoneos.xcarchive/Products/Library/Frameworks/${FRAMEWORK_NAME}"
    
    if [ ! -d "$DEVICE_FRAMEWORK_PATH" ]; then
        echo -e "${RED}❌ iOS Device Framework not found: ${FRAMEWORK_NAME}${NC}"
        exit 1
    fi
    
    echo ""
    echo "Processing framework: $FRAMEWORK_NAME"
    echo "  - iOS Simulator: $SIMULATOR_FRAMEWORK_PATH"
    echo "  - iOS Device: $DEVICE_FRAMEWORK_PATH"
    
    # Create XCFramework
    if ! xcodebuild -create-xcframework \
        -framework "$SIMULATOR_FRAMEWORK_PATH" \
        -framework "$DEVICE_FRAMEWORK_PATH" \
        -output "${XCFRAMEWORK_DIR}/${FRAMEWORK_BASE_NAME}.xcframework"; then
        echo -e "${RED}❌ XCFramework creation failed: ${FRAMEWORK_NAME}${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ ${FRAMEWORK_BASE_NAME}.xcframework created successfully${NC}"
    FRAMEWORK_COUNT=$((FRAMEWORK_COUNT + 1))
done < <(find "${ARCHIVES_DIR}/${PROJECT_NAME}-iphonesimulator.xcarchive" -name "*.framework" -type d -print0)

if [ $FRAMEWORK_COUNT -eq 0 ]; then
    echo -e "${RED}❌ No frameworks were generated${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}Total ${FRAMEWORK_COUNT} XCFrameworks created successfully${NC}"

# Display results
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN} ✅ XCFramework Build Completed!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Generated XCFrameworks:"
for xcframework in "${XCFRAMEWORK_DIR}"/*.xcframework; do
    if [ -d "$xcframework" ]; then
        echo "  - $(basename "$xcframework")"
    fi
done
echo ""

# Display XCFramework directory contents
echo "XCFramework directory contents:"
ls -la "${XCFRAMEWORK_DIR}"
echo ""

rm -rf "$ARCHIVES_DIR"