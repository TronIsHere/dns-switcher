#!/bin/bash
set -euo pipefail

APP_NAME="DNS Switcher"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="$SCRIPT_DIR/build"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"

rm -rf "$BUILD_DIR"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

cp "$SCRIPT_DIR/Assets/AppIcon.icns" "$APP_BUNDLE/Contents/Resources/AppIcon.icns"

swiftc \
  -O \
  -parse-as-library \
  -o "$APP_BUNDLE/Contents/MacOS/$APP_NAME" \
  -framework SwiftUI \
  -framework AppKit \
  "$SCRIPT_DIR"/Sources/*.swift

cp "$SCRIPT_DIR/Info.plist" "$APP_BUNDLE/Contents/Info.plist"

echo "Built: $APP_BUNDLE"
echo "Open with: open \"$APP_BUNDLE\""
