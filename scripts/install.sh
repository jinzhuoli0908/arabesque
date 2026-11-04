#!/bin/bash
# Installs Arabesque for the current user: the input method and the "Arabesque Base" layout.
# The build and registration output goes to build/install.log; the screen shows only the outcome.
# On a terminal it also shows a banner and a spinner; elsewhere (pipes, logs) it prints plain lines.
set -euo pipefail
cd "$(dirname "$0")/.."
source scripts/common.sh
arabesque_use_toolchain || exit 1
LOG=build/install.log
mkdir -p build
: >"$LOG"

# Shows the end of the log for a failed step and stops.
fail() {
    echo "error: $1 failed. The last lines of $LOG:" >&2
    tail -n 20 "$LOG" >&2
    exit 1
}

# Runs a step with its output in the log; stops with the end of the log if it fails.
quietly() {
    local step="$1"
    shift
    "$@" >>"$LOG" 2>&1 || fail "$step"
}

TEAL=$'\033[38;5;37m'; GREEN=$'\033[32m'; BOLD=$'\033[1m'; DIM=$'\033[2m'; RESET=$'\033[0m'
VERSION="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' Resources/Info.plist 2>/dev/null || true)"

# Big letters, teal to gold, in a window at least 74 columns wide; one line in a narrower one.
show_banner() {
    if [ "$(tput cols 2>/dev/null || echo 80)" -ge 74 ]; then
        local colors=(37 73 108 143 178 214) i=0 row
        while IFS= read -r row; do
            printf '\033[38;5;%sm%s%s\n' "${colors[i]}" "$row" "$RESET"
            i=$((i + 1))
        done <<'ART'
 █████╗ ██████╗  █████╗ ██████╗ ███████╗███████╗ ██████╗ ██╗   ██╗███████╗
██╔══██╗██╔══██╗██╔══██╗██╔══██╗██╔════╝██╔════╝██╔═══██╗██║   ██║██╔════╝
███████║██████╔╝███████║██████╔╝█████╗  ███████╗██║   ██║██║   ██║█████╗
██╔══██║██╔══██╗██╔══██║██╔══██╗██╔══╝  ╚════██║██║▄▄ ██║██║   ██║██╔══╝
██║  ██║██║  ██║██║  ██║██████╔╝███████╗███████║╚██████╔╝╚██████╔╝███████╗
╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝ ╚══════╝╚══════╝ ╚══▀▀═╝  ╚═════╝ ╚══════╝
ART
        printf '%s%74s%s\n\n' "$DIM" "$VERSION" "$RESET"
    else
        printf '%sÄ%s %sArabesque%s %s%s%s\n\n' "$BOLD$TEAL" "$RESET" "$BOLD" "$RESET" "$DIM" "$VERSION" "$RESET"
    fi
}

# Draws the spinner until stop_spinner ends it. If install.sh dies first (kill, kill -9), the spinner
# notices within a frame, shows the cursor again and stops.
spin() {
    local frames=(⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏) i=0
    trap 'exit 0' TERM
    while kill -0 "$$" 2>/dev/null; do
        printf '\r%s%s%s Building Arabesque…' "$TEAL" "${frames[i]}" "$RESET"
        i=$(( (i + 1) % 10 ))
        sleep 0.1
    done
    printf '\033[?25h'
}

stop_spinner() {
    kill "$SPINNER" 2>/dev/null || true
    wait "$SPINNER" 2>/dev/null || true
    printf '\r\033[K\033[?25h'
}

if [ -t 1 ]; then
    show_banner
    printf '\033[?25l'
    spin &
    SPINNER=$!
    # Only Ctrl-C is trapped. A trap runs after the build returns, which Ctrl-C ends at once; a plain
    # kill must stop install.sh right away, and the spinner then cleans up after itself.
    trap 'stop_spinner; exit 130' INT
    BUILD_STATUS=0
    scripts/build.sh >>"$LOG" 2>&1 || BUILD_STATUS=$?
    stop_spinner
    trap - INT
    [ "$BUILD_STATUS" -eq 0 ] || fail "the build"
    printf '%s✓%s Built Arabesque.\n\n' "$GREEN" "$RESET"
else
    echo "Building Arabesque…"
    quietly "the build" scripts/build.sh
fi
TOOLS="$(swift build -c release --show-bin-path)/ArabesqueTools"
IM_DIR="$HOME/Library/Input Methods"
KL_DIR="$HOME/Library/Keyboard Layouts"
LAYOUT="Arabesque Base.keylayout"

# Decide the closing advice before anything is replaced.
FIRST_INSTALL=no
if [ ! -d "$IM_DIR/Arabesque.app" ]; then FIRST_INSTALL=yes; fi
LAYOUT_CHANGED=no
if [ -f "$KL_DIR/$LAYOUT" ] && ! cmp -s "Resources/$LAYOUT" "$KL_DIR/$LAYOUT"; then LAYOUT_CHANGED=yes; fi

mkdir -p "$IM_DIR" "$KL_DIR"
killall Arabesque 2>/dev/null || true
rm -rf "$IM_DIR/Arabesque.app"
ditto --noqtn build/Arabesque.app "$IM_DIR/Arabesque.app"
cp -X "Resources/$LAYOUT" "$KL_DIR/$LAYOUT"
# A layout from a downloaded ZIP is quarantined, and macOS puts that flag on its copy even with cp -X.
xattr -dr com.apple.quarantine "$IM_DIR/Arabesque.app" "$KL_DIR/$LAYOUT"
"$TOOLS" register "$KL_DIR/$LAYOUT" >>"$LOG" 2>&1 || true
quietly "registering the input method" "$TOOLS" register "$IM_DIR/Arabesque.app"
"$TOOLS" status "$ARABESQUE_ID" >>"$LOG" 2>&1 || true
if [ "$FIRST_INSTALL" = yes ]; then
    cat <<'MSG'
Installed. Log out and back in, then add Arabesque in
System Settings › Keyboard › Text Input › Input Sources › Edit… › + › English.
MSG
elif [ "$LAYOUT_CHANGED" = yes ]; then
    cat <<'MSG'
Updated. The Arabesque Base layout changed: log out and back in once.
Sandboxed apps such as Safari keep their own copy of the old layout until the next login.
MSG
else
    cat <<'MSG'
Updated. Switch to another input source and back to load the new version; no logout needed.
MSG
fi
