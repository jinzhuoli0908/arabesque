#!/bin/bash
# Builds build/Arabesque.app. The toolchain comes from scripts/common.sh: the Command Line Tools
# when installed (no Xcode license needed), otherwise the selected Xcode.
set -euo pipefail
cd "$(dirname "$0")/.."
source scripts/common.sh
arabesque_use_toolchain || exit 1
APP="build/Arabesque.app"

swift build -c release --product ArabesqueApp
swift build -c release --product ArabesqueTools
BIN="$(swift build -c release --show-bin-path)"

rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp -X "$BIN/ArabesqueApp" "$APP/Contents/MacOS/Arabesque"
cp -X Resources/Info.plist "$APP/Contents/Info.plist"
# Files from a downloaded ZIP are quarantined, and macOS puts that flag on their copies even with cp -X.
xattr -dr com.apple.quarantine "$APP"
"$BIN/ArabesqueTools" icon "$APP/Contents/Resources/icon.tiff"
plutil -lint "$APP/Contents/Info.plist"
codesign --force --sign - "$APP"
codesign --verify --deep --strict "$APP"
echo "built $APP"
