#!/usr/bin/env bash
set -euo pipefail

BINARY_NAME="git-dl"
TARGET="$HOME/.local/bin/$BINARY_NAME"

if [ ! -f "$TARGET" ]; then
    echo "$BINARY_NAME is not installed."
    exit 0
fi

rm "$TARGET"
echo "Uninstalled: $TARGET"
