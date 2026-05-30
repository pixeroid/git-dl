#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE="$SCRIPT_DIR/git-dl.sh"
BINARY_NAME="git-dl"

# Find first user-writable bin directory on PATH
TARGET_DIR=""
IFS=: read -ra path_dirs <<< "$PATH"
for dir in "${path_dirs[@]}"; do
    if [[ -d "$dir" && -w "$dir" ]]; then
        TARGET_DIR="$dir"
        break
    fi
done

[ -z "$TARGET_DIR" ] && { echo "Error: No user-writable bin directory found on PATH." >&2; exit 1; }

TARGET="$TARGET_DIR/$BINARY_NAME"
cp "$SOURCE" "$TARGET"
chmod +x "$TARGET"

echo "Installed to: $TARGET"
