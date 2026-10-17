#!/bin/bash
# Builds "Nothing X.app" with Swift Package Manager — no Xcode required, only the
# Command Line Tools (`xcode-select --install`).
#
#   scripts/build-app.sh             # build into build/Nothing X.app
#   scripts/build-app.sh --install   # ...and copy to /Applications, then launch
#
# Without Xcode there is no asset catalog compiler (actool), so images are copied
# into Resources as loose PNGs and the app icon is built with iconutil.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/Nothing X MacOS"
ASSETS="$SRC/Assets.xcassets"
APP="$ROOT/build/Nothing X.app"
BUNDLE_ID="${BUNDLE_ID:-io.github.indibyte.nothing-x-macos}"
VERSION="$(git -C "$ROOT" describe --tags --always 2>/dev/null || echo 1.0)"

echo "==> Compiling (release)"
swift build -c release --package-path "$ROOT"
BIN="$(swift build -c release --package-path "$ROOT" --show-bin-path)/Nothing_X_MacOS"

echo "==> Assembling $APP"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$BIN" "$APP/Contents/MacOS/Nothing X"
cp "$SRC/resources/fonts/"* "$APP/Contents/Resources/"

# Imagesets -> name.png / name@2x.png / name@3x.png
for set in "$ASSETS"/*.imageset; do
    name="$(basename "$set" .imageset)"
    /usr/bin/python3 -I -c '
import json, sys
for i in json.load(open(sys.argv[1]))["images"]:
    if "filename" in i:
        print(i["scale"] + "\t" + i["filename"])
' "$set/Contents.json" | while IFS=$'\t' read -r scale file; do
        case "$scale" in 2x) suffix="@2x" ;; 3x) suffix="@3x" ;; *) suffix="" ;; esac
        cp "$set/$file" "$APP/Contents/Resources/$name$suffix.png"
    done
done

# App icon
ICONSET="$(mktemp -d)/AppIcon.iconset"
mkdir -p "$ICONSET"
for size in 16 32 128 256 512; do
    cp "$ASSETS/AppIcon.appiconset/AppIcon-$size.png" "$ICONSET/icon_${size}x${size}.png"
    cp "$ASSETS/AppIcon.appiconset/AppIcon-${size}_2x.png" "$ICONSET/icon_${size}x${size}@2x.png"
done
iconutil -c icns "$ICONSET" -o "$APP/Contents/Resources/AppIcon.icns"

cat > "$APP/Contents/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleExecutable</key><string>Nothing X</string>
	<key>CFBundleIdentifier</key><string>$BUNDLE_ID</string>
	<key>CFBundleName</key><string>Nothing X</string>
	<key>CFBundleDisplayName</key><string>Nothing X</string>
	<key>CFBundlePackageType</key><string>APPL</string>
	<key>CFBundleShortVersionString</key><string>$VERSION</string>
	<key>CFBundleVersion</key><string>1</string>
	<key>CFBundleIconFile</key><string>AppIcon</string>
	<key>LSMinimumSystemVersion</key><string>13.0</string>
	<key>LSUIElement</key><true/>
	<key>LSApplicationCategoryType</key><string>public.app-category.utilities</string>
	<key>NSBluetoothAlwaysUsageDescription</key><string>This app uses Bluetooth to find and maintain connections to your Nothing and CMF earbuds.</string>
	<key>NSBluetoothPeripheralUsageDescription</key><string>This app uses Bluetooth to find and maintain connections to your Nothing and CMF earbuds.</string>
	<key>ATSApplicationFontsPath</key><string>.</string>
	<key>NSPrincipalClass</key><string>NSApplication</string>
</dict>
</plist>
EOF

echo "==> Signing (ad-hoc)"
codesign --force --deep --sign - --entitlements "$SRC/Nothing_X_MacOS.entitlements" "$APP"

if [[ "${1:-}" == "--install" ]]; then
    echo "==> Installing to /Applications"
    pkill -x "Nothing X" 2>/dev/null && sleep 1 || true
    rm -rf "/Applications/Nothing X.app"
    cp -R "$APP" /Applications/
    open "/Applications/Nothing X.app"
fi

echo "==> Done: $APP"
