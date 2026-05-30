#!/usr/bin/env bash
set -euo pipefail

URL=""

usage() {
    echo "Usage: git-dl2 <github-url>"
    echo ""
    echo "  Downloads a GitHub repo, folder, or file without cloning."
    exit 1
}

die() { echo "Error: $1" >&2; exit 1; }

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help) usage ;;
        -*) die "Unknown flag: $1" ;;
        *)
            [ -n "$URL" ] && die "Too many arguments."
            URL="$1"
            shift
            ;;
    esac
done

[ -z "$URL" ] && usage

command -v git &>/dev/null || die "git is not available."

# Strip trailing slash and .git suffix
URL="${URL%/}"
URL="${URL%.git}"

# Parse: https://github.com/OWNER/REPO[/(tree|blob)/BRANCH[/SUBPATH]]
regex='^https://github\.com/([^/]+)/([^/]+)(/((tree|blob)/(.+))?)?$'
[[ "$URL" =~ $regex ]] || die "Unrecognised GitHub URL: $URL"

OWNER="${BASH_REMATCH[1]}"
REPO="${BASH_REMATCH[2]}"
TYPE="${BASH_REMATCH[5]}"   # "tree", "blob", or ""
REST="${BASH_REMATCH[6]}"   # BRANCH[/SUBPATH] or ""

BRANCH="" SUBPATH=""
if [ -n "$REST" ]; then
    BRANCH="${REST%%/*}"
    SUBPATH="${REST#*/}"
    [ "$SUBPATH" = "$REST" ] && SUBPATH=""
    SUBPATH="${SUBPATH%/}"
fi

if [ -z "$TYPE" ]; then
    MODE="repo"
elif [ "$TYPE" = "blob" ]; then
    MODE="file"
    [ -z "$SUBPATH" ] && die "File URL must include a file path after the branch name."
else
    MODE="folder"
    [ -z "$SUBPATH" ] && die "Folder URL must include a folder path after the branch name."
fi

case "$MODE" in
    repo)   TARGET="$REPO" ;;
    folder) TARGET="$(basename "$SUBPATH")" ;;
    file)   TARGET="$(basename "$SUBPATH")" ;;
esac

[ -e "$TARGET" ] && die "'$TARGET' already exists in the current directory. Remove it first."

REMOTE="https://github.com/$OWNER/$REPO.git"

branch_args=()
if [ -n "$BRANCH" ]; then
    branch_args=(--branch "$BRANCH")
fi

case "$MODE" in
    repo)
        git clone --depth=1 "${branch_args[@]+"${branch_args[@]}"}" "$REMOTE" "$TARGET"
        git -C "$TARGET" remote remove origin
        ;;
    folder)
        workdir=$(mktemp -d /tmp/git-dl-XXXXXX)
        local_clone="$workdir/repo"
        git clone --depth=1 --filter=blob:none --sparse "${branch_args[@]+"${branch_args[@]}"}" "$REMOTE" "$local_clone"
        git -C "$local_clone" sparse-checkout set "$SUBPATH"
        [ -d "$local_clone/$SUBPATH" ] || die "Path '$SUBPATH' not found in the repository."
        mv "$local_clone/$SUBPATH" "$TARGET"
        ;;
    file)
        workdir=$(mktemp -d /tmp/git-dl-XXXXXX)
        local_clone="$workdir/repo"
        git clone --depth=1 --filter=blob:none --sparse "${branch_args[@]+"${branch_args[@]}"}" "$REMOTE" "$local_clone"
        git -C "$local_clone" sparse-checkout set --no-cone "$SUBPATH"
        [ -f "$local_clone/$SUBPATH" ] || die "File '$SUBPATH' not found in the repository."
        mv "$local_clone/$SUBPATH" "$TARGET"
        ;;
esac

echo "Downloaded to: $TARGET"
