#!/bin/bash
# Removes Arabesque: switches to another keyboard layout, disables the input source and the
# "Arabesque Base" layout, then deletes the app and the layout file. The output of these steps
# goes to build/uninstall.log; the screen shows only progress, the outcome and any warning.
set -euo pipefail
cd "$(dirname "$0")/.."
source scripts/common.sh
BASE_NAME="Arabesque Base"
LOG=build/uninstall.log
mkdir -p build
: >"$LOG"

# Find ArabesqueTools, compiling only when there is no copy to reuse. With a usable toolchain, take
# the release build and build it if it is missing; without one, take any copy a past build left behind.
TOOLS=""
if arabesque_use_toolchain 2>>"$LOG" && BIN="$(swift build -c release --show-bin-path 2>>"$LOG")"; then
    TOOLS="$BIN/ArabesqueTools"
    if [ ! -x "$TOOLS" ]; then
        echo "Preparing to uninstall…"
        if ! swift build -c release --product ArabesqueTools >>"$LOG" 2>&1; then
            TOOLS=""
        fi
    fi
else
    TOOLS="$(find .build -type f -name ArabesqueTools -perm -u+x 2>/dev/null | head -n 1 || true)"
fi

if [ -n "$TOOLS" ]; then
    # A failing step never stops the removal. Switch away first, so that disabling the input source
    # does not leave it selected; the base layout is excluded because it is about to be disabled too.
    if FALLBACK="$("$TOOLS" fallback-layout "$BASE_NAME" 2>>"$LOG")"; then
        "$TOOLS" select "$FALLBACK" >>"$LOG" 2>&1 || true
    else
        echo "warning: could not choose a keyboard layout to switch to; left the current input source as it is" >&2
    fi
    "$TOOLS" disable "$ARABESQUE_ID" >>"$LOG" 2>&1 || true
    if BASE_ID="$("$TOOLS" find-layout "$BASE_NAME" 2>>"$LOG")"; then
        "$TOOLS" disable "$BASE_ID" >>"$LOG" 2>&1 || true
    fi
else
    echo "warning: could not build ArabesqueTools; skipped deselecting and disabling the input source (see $LOG)" >&2
fi
killall Arabesque 2>/dev/null || true
rm -rf "$HOME/Library/Input Methods/Arabesque.app" "$HOME/Library/Keyboard Layouts/Arabesque Base.keylayout"
echo "Removed. Log out and back in to clear Arabesque from the input source list and from app caches."
