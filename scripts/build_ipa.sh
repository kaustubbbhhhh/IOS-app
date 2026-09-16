#!/bin/bash
set -e

# ==============================================================================
# OffScreen iOS App - Build & IPA Export Script
# Usage: ./scripts/build_ipa.sh [version] [configuration]
# Example: ./scripts/build_ipa.sh 1.0.0 Release
# ==============================================================================

VERSION="${1:-1.0.0}"
CONFIG="${2:-Release}"
SCHEME="OffScreen"
BUILD_DIR="./build"
ARCHIVE_PATH="${BUILD_DIR}/OffScreen.xcarchive"
IPA_DIR="${BUILD_DIR}/ipa"
FINAL_IPA="./OffScreen-v${VERSION}-ios17-${CONFIG,,}.ipa"

echo "========================================================"
echo "🚀 Building OffScreen iOS App v${VERSION} (${CONFIG})"
echo "========================================================"

# Step 1: Clean build directory
rm -rf "${BUILD_DIR}"
mkdir -p "${IPA_DIR}"

# Step 2: Archive the project
echo "📦 Step 1/3: Archiving project..."
xcodebuild archive \
  -scheme "${SCHEME}" \
  -configuration "${CONFIG}" \
  -destination "generic/platform=iOS" \
  -archivePath "${ARCHIVE_PATH}" \
  CODE_SIGNING_ALLOWED=YES

# Step 3: Export the IPA
echo "📤 Step 2/3: Exporting IPA..."
xcodebuild -exportArchive \
  -archivePath "${ARCHIVE_PATH}" \
  -exportPath "${IPA_DIR}" \
  -exportOptionsPlist "./ExportOptions.plist"

# Step 4: Rename and move IPA
echo "🏷️ Step 3/3: Packaging installer..."
SOURCE_IPA="${IPA_DIR}/${SCHEME}.ipa"

if [ -f "${SOURCE_IPA}" ]; then
    cp "${SOURCE_IPA}" "${FINAL_IPA}"
    echo "========================================================"
    echo "✅ Successfully generated installer: ${FINAL_IPA}"
    echo "========================================================"
else
    echo "❌ Error: IPA export failed. Look for logs in ${BUILD_DIR}"
    exit 1
fi
