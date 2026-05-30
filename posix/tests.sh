#!/usr/bin/env bash
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GIT_DL="$SCRIPT_DIR/git-dl.sh"
PASS=0
FAIL=0

pass() { echo "  PASS: $1"; ((PASS++)); }
fail() { echo "  FAIL: $1"; ((FAIL++)); }

# Run git-dl with given args; check that expected_path exists (or not) in the tmpdir.
# Usage: run_test <description> <expected_path> <expect_exists: 0|1> [git-dl args...]
run_test() {
    local description="$1" expected_path="$2" expect_exists="$3"
    shift 3

    local tmpdir result=0
    tmpdir=$(mktemp -d)
    (cd "$tmpdir" && "$GIT_DL" "$@") 2>/dev/null || result=$?

    if [ "$expect_exists" -eq 1 ] && [ -e "$tmpdir/$expected_path" ]; then
        pass "$description"
    elif [ "$expect_exists" -eq 0 ] && [ "$result" -ne 0 ]; then
        pass "$description"
    else
        fail "$description"
    fi

    rm -rf "$tmpdir"
}

echo ""
echo "=== Checking git-dl exists and is executable ==="
if [ -x "$GIT_DL" ]; then
    pass "git-dl exists and is executable"
else
    fail "git-dl not found or not executable"
fi

echo ""
echo "=== Use case 1: Download full repo ==="
run_test "Downloads repo into folder named after the repo" "dotenv" 1 \
    "https://github.com/motdotla/dotenv"
run_test "Repo folder contains expected top-level file" "dotenv/README.md" 1 \
    "https://github.com/motdotla/dotenv"

echo ""
echo "=== Use case 2: Download specific folder ==="
run_test "Downloads folder into directory named after the folder" "dotenv" 1 \
    "https://github.com/motdotla/dotenv/tree/master/skills/dotenv"
run_test "Downloaded folder contains expected files" "dotenv/SKILL.md" 1 \
    "https://github.com/motdotla/dotenv/tree/master/skills/dotenv"

echo ""
echo "=== Use case 3: Download specific file ==="
run_test "Downloads file directly into CWD" "SKILL.md" 1 \
    "https://github.com/motdotla/dotenv/blob/master/skills/dotenv/SKILL.md"

echo ""
echo "=== Conflict handling ==="

# Pre-seed the tmpdir then run; reuse run_test's expect_exists=0 path
tmpdir=$(mktemp -d); mkdir -p "$tmpdir/dotenv"
result=0; (cd "$tmpdir" && "$GIT_DL" "https://github.com/motdotla/dotenv") 2>/dev/null || result=$?
[ "$result" -ne 0 ] && pass "Exits with error when target folder already exists" || fail "Should error when target folder already exists"
rm -rf "$tmpdir"

tmpdir=$(mktemp -d); touch "$tmpdir/SKILL.md"
result=0; (cd "$tmpdir" && "$GIT_DL" "https://github.com/motdotla/dotenv/blob/master/skills/dotenv/SKILL.md") 2>/dev/null || result=$?
[ "$result" -ne 0 ] && pass "Exits with error when target file already exists" || fail "Should error when target file already exists"
rm -rf "$tmpdir"

echo ""
echo "=== Script safety ==="
if grep -qE '\brm\b' "$GIT_DL"; then
    fail "Script contains 'rm' command"
else
    pass "Script contains no 'rm' command"
fi

echo ""
echo "=== No arguments ==="
run_test "Exits with non-zero when called with no arguments" "" 0

echo ""
echo "================================"
echo "  Results: $PASS passed, $FAIL failed"
echo "================================"
echo ""

[ "$FAIL" -eq 0 ]
