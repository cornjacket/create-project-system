#!/usr/bin/env bash
# Create a new epic directory with all status subdirectories.
#
# Without --project: creates <tasks-root>/<epic-name>/
# With --project:    creates <projects-root>/<project-name>/<epic-name>/
#
# --repair operates on an epic that ALREADY exists: it creates any status folder
# (and its seeded README) that is missing and touches nothing that is already
# there. Use it when the folder vocabulary grows — an install generated before
# `inbox` existed would otherwise stay permanently short a folder, because
# regeneration preserves an existing epic whole. It is safe to run any time:
# with nothing missing it writes nothing.
#
# Usage:
#   new-epic.sh --name <epic-name> [--project <project-name>]
#   new-epic.sh --repair --name <epic-name> [--project <project-name>] [--porcelain]
#
# Examples:
#   new-epic.sh --name main
#   new-epic.sh --name main --project my-project
#   new-epic.sh --repair --name main            # backfill missing status folders

set -euo pipefail

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPTS_DIR/task-env.sh"

# ---------------------------------------------------------------------------
# Parse arguments
# ---------------------------------------------------------------------------

NAME=""
PROJECT=""
REPAIR=false
PORCELAIN=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --name)      NAME="$2";    shift 2 ;;
        --project)   PROJECT="$2"; shift 2 ;;
        --repair)    REPAIR=true;  shift ;;
        --porcelain) PORCELAIN=true; shift ;;
        *) echo "Unknown flag: $1"; exit 1 ;;
    esac
done

if [[ -z "$NAME" ]]; then
    echo "Usage: new-epic.sh [--repair] --name <epic-name> [--project <project-name>] [--porcelain]"
    exit 1
fi

if [[ "$PORCELAIN" == true && "$REPAIR" != true ]]; then
    echo "--porcelain is only meaningful with --repair." >&2
    exit 1
fi

# ---------------------------------------------------------------------------
# Resolve base path
# ---------------------------------------------------------------------------

if [[ -n "$PROJECT" ]]; then
    BASE_DIR="$PROJECTS_ROOT/$PROJECT"
    if [[ ! -d "$BASE_DIR" ]]; then
        echo "Project directory not found: $BASE_DIR"
        echo "Run new-project.sh --name $PROJECT first."
        exit 1
    fi
    EPIC_DIR="$BASE_DIR/$NAME"
    DISPLAY_PATH="$PROJECTS_REL/$PROJECT/$NAME"
else
    BASE_DIR="$TASKS_ROOT"
    EPIC_DIR="$BASE_DIR/$NAME"
    DISPLAY_PATH="$TASKS_REL/$NAME"
fi

# ---------------------------------------------------------------------------
# Status folder seeding
# ---------------------------------------------------------------------------
# The status vocabulary is TASK_STATUSES, defined once in task-env.sh.

# write_status_readme <status> — the empty-task-list template for one folder.
# Only ever called for a README that does not exist: this file grows the
# task-list block that holds real task ordering, so overwriting one loses work.
write_status_readme() {
    cat > "$EPIC_DIR/$1/README.md" << EOF
# $NAME / $1

## Tasks

<!-- When a task is finished, run move-task.sh --to complete before moving on. -->
<!-- task-list-start -->
<!-- task-list-end -->
EOF
}

# ---------------------------------------------------------------------------
# --repair: backfill missing status folders in an existing epic
# ---------------------------------------------------------------------------
if [[ "$REPAIR" == true ]]; then
    if [[ ! -d "$EPIC_DIR" ]]; then
        echo "Epic not found: $DISPLAY_PATH" >&2
        echo "Run without --repair to create it." >&2
        exit 1
    fi

    backfilled=()
    for STATUS in "${TASK_STATUSES[@]}"; do
        # A missing status folder is not content — it holds no task, so creating
        # it destroys nothing. An existing one is left byte-identical.
        if [[ ! -d "$EPIC_DIR/$STATUS" || ! -f "$EPIC_DIR/$STATUS/README.md" ]]; then
            mkdir -p "$EPIC_DIR/$STATUS"
            [[ -f "$EPIC_DIR/$STATUS/README.md" ]] || write_status_readme "$STATUS"
            backfilled+=("$STATUS")
        fi
    done

    if [[ "$PORCELAIN" == true ]]; then
        # Machine interface: one backfilled status name per line, nothing else.
        # (An `&&` one-liner would exit 1 here under `set -e` when nothing was
        # missing — the common case — so this stays an if.)
        if [[ ${#backfilled[@]} -gt 0 ]]; then
            printf '%s\n' "${backfilled[@]}"
        fi
        exit 0
    fi

    if [[ ${#backfilled[@]} -eq 0 ]]; then
        echo "Nothing to repair: $DISPLAY_PATH has all ${#TASK_STATUSES[@]} status folders."
    else
        echo "Backfilled in $DISPLAY_PATH:"
        for STATUS in "${backfilled[@]}"; do echo "  + $STATUS/"; done
        echo "Note: the epic README's status table is content and was not rewritten —"
        echo "      add the row(s) by hand if you want the new folders listed there."
    fi
    exit 0
fi

# ---------------------------------------------------------------------------
# Create epic directory and status subdirectories
# ---------------------------------------------------------------------------

if [[ -d "$EPIC_DIR" ]]; then
    echo "Epic already exists: $DISPLAY_PATH"
    echo "  To backfill any missing status folders: new-epic.sh --repair --name $NAME"
    exit 1
fi

mkdir -p "$EPIC_DIR"

for STATUS in "${TASK_STATUSES[@]}"; do
    mkdir -p "$EPIC_DIR/$STATUS"
    write_status_readme "$STATUS"
done

# Epic-level README
{
    echo "# Epic: $NAME"
    echo ""
    echo "## Status"
    echo ""
    echo "| Status      | Tasks |"
    echo "|-------------|-------|"
    for STATUS in "${TASK_STATUSES[@]}"; do
        printf '| %-11s |       |\n' "$STATUS"
    done
} > "$EPIC_DIR/README.md"

# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------

echo "Created epic: $DISPLAY_PATH"
echo "  Subdirectories: ${TASK_STATUSES[*]}"
