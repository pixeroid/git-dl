#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE="$SCRIPT_DIR/git-dl.sh"
BINARY_NAME="git-dl"
TARGET_DIR="$HOME/.local/bin"
TARGET="$TARGET_DIR/$BINARY_NAME"

mkdir -p "$TARGET_DIR"
cp "$SOURCE" "$TARGET"
chmod +x "$TARGET"

echo "Installed to: $TARGET"

# Add to PATH if not already present
if [[ ":$PATH:" != *":$TARGET_DIR:"* ]]; then
    SHELL_RC=""
    case "$SHELL" in
        */zsh)  SHELL_RC="$HOME/.zshrc" ;;
        */bash) SHELL_RC="$HOME/.bashrc" ;;
    esac

    if [[ -n "$SHELL_RC" ]]; then
        echo "" >> "$SHELL_RC"
        echo "# Added by git-dl installer" >> "$SHELL_RC"
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$SHELL_RC"
        echo "Added $TARGET_DIR to PATH in $SHELL_RC"
        echo "Run 'source $SHELL_RC' or open a new shell to apply."
    else
        echo "Note: $TARGET_DIR is not in PATH. Add it manually to your shell config."
    fi
fi
