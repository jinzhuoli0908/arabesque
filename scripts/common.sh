# Shared setup for the scripts in this folder. Source it after changing to the repository root:
#   source scripts/common.sh
# It sets ARABESQUE_ID and defines arabesque_use_toolchain. Sourcing never exits the calling shell.

# The bundle ID is read from Info.plist, so the scripts never hard-code it.
if ! ARABESQUE_ID="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' Resources/Info.plist)"; then
    ARABESQUE_ID=""
    echo "warning: could not read CFBundleIdentifier from Resources/Info.plist" >&2
fi

# Chooses the Swift toolchain, exporting DEVELOPER_DIR when needed; returns 1 if none is found.
# A DEVELOPER_DIR you set yourself is kept. Without one, the Command Line Tools are used when
# installed (no Xcode license needed); if they are missing too, xcrun follows `xcode-select -p`.
arabesque_use_toolchain() {
    local clt=/Library/Developer/CommandLineTools
    if [ -z "${DEVELOPER_DIR:-}" ] && [ -x "$clt/usr/bin/swift" ]; then
        export DEVELOPER_DIR="$clt"
    fi
    if ! xcrun --find swift >/dev/null; then
        echo "error: no Swift toolchain found. Install the Command Line Tools with: xcode-select --install" >&2
        return 1
    fi
}
