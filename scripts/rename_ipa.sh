#!/bin/bash
# ==============================================================================
# OffScreen iOS App - Post-Build IPA Renaming Script
# Usage: ./scripts/rename_ipa.sh <version> <build-type>
# Example: ./scripts/rename_ipa.sh 1.0.0 debug
# Produces: OffScreen-v1.0.0-ios17-debug.ipa
# ==============================================================================

VERSION="${1:-1.0.0}"
BUILD_TYPE="${2:-debug}"
MIN_IOS="ios17"
SOURCE="./build/ipa/OffScreen.ipa"
OUTPUT="./OffScreen-v${VERSION}-${MIN_IOS}-${BUILD_TYPE}.ipa"

if [ -f "$SOURCE" ]; then
    cp "$SOURCE" "$OUTPUT"
    echo "✅ Created: $OUTPUT"
else
    echo "❌ IPA not found at $SOURCE"
    exit 1
fi
