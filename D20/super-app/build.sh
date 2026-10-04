#!/usr/bin/env bash
# Usage: ./build.sh [debug|release]
set -euo pipefail

config="${1:-debug}"
cd "$(dirname "$0")"

cmake --preset default
cmake --build --preset "$config"
