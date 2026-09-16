#!/bin/bash
# Build a signed Release Tinycast.app and install it over /Applications/Tinycast.app, replacing
# whatever is there. Same bundle id (com.tinycast.app), so existing settings/history carry over.
# Usage: ./Scripts/install-local.sh [version]
set -euo pipefail

cd "$(dirname "$0")/.." || exit 1
export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"
IDENTITY="Tinycast Self-Signed"
DERIVED="build/DerivedData"
DEST="/Applications/Tinycast.app"

if ! security find-identity -p codesigning | grep -q "$IDENTITY"; then
    echo "✗ '$IDENTITY' code-signing identity not found — create it once (docs/signing.md)." >&2
    exit 1
fi

echo "▸ Building signed Tinycast.app (Release)…"
xcodebuild -project Tinycast.xcodeproj -scheme Tinycast -configuration Release \
    -derivedDataPath "$DERIVED" \
    CODE_SIGN_STYLE=Manual CODE_SIGN_IDENTITY="$IDENTITY" OTHER_CODE_SIGN_FLAGS="--timestamp=none" \
    ${1:+MARKETING_VERSION="$1"} \
    build

APP="$DERIVED/Build/Products/Release/Tinycast.app"

if pgrep -qx Tinycast; then
    echo "▸ Quitting the running Tinycast.app…"
    osascript -e 'tell application "Tinycast" to quit' >/dev/null 2>&1 || true
    for _ in $(seq 1 20); do
        pgrep -qx Tinycast || break
        sleep 0.25
    done
    pkill -x Tinycast 2>/dev/null || true
fi

echo "▸ Installing to $DEST"
rm -rf "$DEST"
cp -R "$APP" "$DEST"

echo "▸ Launching"
open "$DEST"

VERSION="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$DEST/Contents/Info.plist")"
echo "✓ Installed Tinycast $VERSION to $DEST"
