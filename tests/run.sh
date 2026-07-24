#!/usr/bin/env bash
# tests/run.sh — golden / reproducibility test.
#
# Regenerates each fixture into a temp dir and diffs it against the checked-in
# expected tree under tests/golden/. Any drift — a changed script, a new file, a
# rename — fails the test with a readable diff.
#
# Usage:
#   bash tests/run.sh            # verify against golden fixtures
#   bash tests/run.sh --update   # regenerate the fixtures (intentional refresh)
#
# When you INTENTIONALLY change the generated output (edit a script in src/, add
# a file, change the CLAUDE.md kernel), the golden test will fail — that is
# working as designed. Review the diff, and if the change is intended, refresh
# the fixtures with `bash tests/run.sh --update` and commit them alongside the
# source change so the diff is visible in review.
#
# Determinism note: the generated tree contains no timestamps or random IDs
# (those are minted only at task-creation time), so identical inputs produce
# byte-identical output. The fixtures pin exactly that.

set -u
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GEN="$REPO/generate.sh"
GOLDEN="$REPO/tests/golden"
UPDATE=false
[[ "${1:-}" == "--update" ]] && UPDATE=true

# name -> generate.sh flags
fixture_flags() {
    case "$1" in
        core)       echo "" ;;
        all-layers) echo "--with-classes --with-projects --with-worktree-guard --with-skill" ;;
        *) echo "UNKNOWN"; return 1 ;;
    esac
}
FIXTURES=(core all-layers)

# Generate one fixture into $2, stripped of git metadata.
generate_into() {
    local name="$1" dst="$2"
    ( cd "$dst" && git init -q && git config user.email golden@local && git config user.name golden )
    # shellcheck disable=SC2046
    "$GEN" --target-repo "$dst" --tasks-dir tasks --epic main $(fixture_flags "$name") >/dev/null 2>&1
    rm -rf "$dst/.git"
}

if [[ "$UPDATE" == true ]]; then
    echo "Refreshing golden fixtures:"
    for name in "${FIXTURES[@]}"; do
        tmp="$(mktemp -d)"; generate_into "$name" "$tmp"
        rm -rf "$GOLDEN/$name"; mkdir -p "$GOLDEN/$name"; cp -R "$tmp"/. "$GOLDEN/$name/"; rm -rf "$tmp"
        echo "  updated $name ($(find "$GOLDEN/$name" -type f | wc -l | tr -d ' ') files)"
    done
    echo "Review 'git diff tests/golden/' and commit if intended."
    exit 0
fi

FAIL=0
for name in "${FIXTURES[@]}"; do
    if [[ ! -d "$GOLDEN/$name" ]]; then
        echo "MISSING fixture: tests/golden/$name — run: bash tests/run.sh --update" >&2
        FAIL=$((FAIL+1)); continue
    fi
    tmp="$(mktemp -d)"; generate_into "$name" "$tmp"
    if diff -r "$GOLDEN/$name" "$tmp" >/tmp/golden-diff.$$  2>&1; then
        echo "✓ $name — matches golden ($(find "$GOLDEN/$name" -type f | wc -l | tr -d ' ') files)"
    else
        echo "✗ $name — DRIFT from golden:"
        sed 's/^/    /' /tmp/golden-diff.$$
        echo "    If this change is intended: bash tests/run.sh --update && commit tests/golden/"
        FAIL=$((FAIL+1))
    fi
    rm -rf "$tmp" /tmp/golden-diff.$$
done

echo ""
if [[ $FAIL -eq 0 ]]; then echo "GOLDEN OK — all fixtures reproduce byte-for-byte"; else echo "$FAIL fixture(s) drifted"; fi
exit $FAIL
