#!/bin/bash
# Runs the test suite. With only Command Line Tools installed, SwiftPM does not load the
# swift-testing macro plugin (it sits in plugins/testing/), so pass that folder explicitly.
# SwiftPM 6.2 and 6.3 (Command Line Tools 26) also pass the folder that holds Testing.framework
# with -I instead of -F, so `import Testing` fails. Pass it with -F, and add it to the rpath
# so that the tests can load the framework. The framework in turn loads lib_TestingInterop.dylib
# from Library/Developer/usr/lib, which its own rpaths miss in the Command Line Tools layout,
# so that folder goes into the rpath as well.
set -euo pipefail
cd "$(dirname "$0")/.."
source scripts/common.sh
arabesque_use_toolchain || exit 1
BIN="$(dirname "$(xcrun --find swift)")"
FLAGS=()
PLUGINS="$BIN/../lib/swift/host/plugins/testing"
if [ -d "$PLUGINS" ]; then
    FLAGS+=(-Xswiftc -plugin-path -Xswiftc "$PLUGINS")
fi
FRAMEWORKS="$BIN/../../Library/Developer/Frameworks"
INTEROP="$BIN/../../Library/Developer/usr/lib"
case "$(swift --version 2>&1)" in
    *"Swift version 6.2"* | *"Swift version 6.3"*)
        if [ -d "$FRAMEWORKS/Testing.framework" ]; then
            FLAGS+=(-Xswiftc -F -Xswiftc "$FRAMEWORKS" -Xlinker -rpath -Xlinker "$FRAMEWORKS")
        fi
        if [ -f "$INTEROP/lib_TestingInterop.dylib" ]; then
            FLAGS+=(-Xlinker -rpath -Xlinker "$INTEROP")
        fi
        ;;
esac
exec swift test ${FLAGS[@]+"${FLAGS[@]}"} "$@"
