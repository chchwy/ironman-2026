#!/usr/bin/env bash
# Usage: ./build.sh [debug|release]
set -euo pipefail

case "${1:-debug}" in
    debug)   build_type=Debug ;;
    release) build_type=Release ;;
    *)       echo "Usage: $0 [debug|release]" >&2; exit 1 ;;
esac

: "${VCPKG_ROOT:?VCPKG_ROOT is not set}"

cd "$(dirname "$0")"
overlay_ports="$(cd ../my-ports && pwd)"

# CMAKE_BUILD_TYPE is for single-config generators (Makefile, Ninja);
# --config is for multi-config ones (Visual Studio, Xcode)
cmake -S . -B build \
    -DCMAKE_TOOLCHAIN_FILE="$VCPKG_ROOT/scripts/buildsystems/vcpkg.cmake" \
    -DVCPKG_OVERLAY_PORTS="$overlay_ports" \
    -DCMAKE_BUILD_TYPE="$build_type"
cmake --build build --config "$build_type"
