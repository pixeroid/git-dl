#!/usr/bin/env bash
set -euo pipefail

BINARY_NAME="git-dl"
TARGET="$(command -v "$BINARY_NAME" 2>/dev/null || true)"

if [ -z "$TARGET" ]; then
    echo "$BINARY_NAME is not installed."
    exit 0
fi

rm "$TARGET"
echo "Uninstalled: $TARGET"
