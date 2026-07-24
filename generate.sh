#!/usr/bin/env bash
# generate.sh — install the Markdown task subsystem into a target repo.
#
# Usage:
#   generate.sh --target-repo <path> [options]
#
# Options:
#   --target-repo <path>     Repo to install into (required)
#   --tasks-dir <rel-path>   Mount path inside the target (default: tasks)
#   --epic <name>            Starter epic (default: main)
#   --with-classes           Worktree categories (classes.md + Category field)
#   --with-projects          Long-running projects (new-project.sh, list-projects.sh)
#   --with-worktree-guard    check-task-complete.py removal guard
#   --with-skill             Emit .claude/skills/task-system/ (Claude on-demand skill)
#   --inject-claude-md       Append the kernel snippet to the target's CLAUDE.md
#                            (default: print it for manual placement)
#   --force                  Also re-seed content (classes.md, status task lists).
#                            NOT needed for normal regeneration — see below.
#   -h, --help               Show this help
#
# COLLISION POLICY — regeneration is safe by default:
#   * MACHINERY (scripts/, templates, docs/, task-config.sh, skill) is ALWAYS
#     overwritten. It is generated output; that is the point.
#   * CONTENT (epic + status folders, their task lists, classes.md) is created
#     ONLY IF MISSING and is never overwritten. Your tasks are never touched.
#   So re-running the same command upgrades the machinery and leaves task content
#   alone. --force additionally re-seeds content files (rarely wanted).

set -euo pipefail

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/src" && pwd)"

# ---------------------------------------------------------------------------
# Arguments
# ---------------------------------------------------------------------------
TARGET=""
TASKS_DIR="tasks"
EPIC="main"
WITH_CLASSES=false
WITH_PROJECTS=false
WITH_GUARD=false
WITH_SKILL=false
INJECT_CLAUDE_MD=false
FORCE=false

usage() { sed -n '2,30p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; }

while [[ $# -gt 0 ]]; do
    case "$1" in
        --target-repo)        TARGET="$2"; shift 2 ;;
        --tasks-dir)          TASKS_DIR="$2"; shift 2 ;;
        --epic)               EPIC="$2"; shift 2 ;;
        --with-classes)       WITH_CLASSES=true; shift ;;
        --with-projects)      WITH_PROJECTS=true; shift ;;
        --with-worktree-guard) WITH_GUARD=true; shift ;;
        --with-skill)         WITH_SKILL=true; shift ;;
        --inject-claude-md)   INJECT_CLAUDE_MD=true; shift ;;
        --force)              FORCE=true; shift ;;
        -h|--help)            usage; exit 0 ;;
        *) echo "Unknown flag: $1" >&2; echo "Try --help" >&2; exit 1 ;;
    esac
done

if [[ -z "$TARGET" ]]; then
    echo "Error: --target-repo is required." >&2
    echo "Try --help" >&2
    exit 1
fi
if [[ ! -d "$TARGET" ]]; then
    echo "Error: target repo not found: $TARGET" >&2
    exit 1
fi
TARGET="$(cd "$TARGET" && pwd)"

# Strip any leading/trailing slashes from the mount path
TASKS_DIR="${TASKS_DIR#/}"; TASKS_DIR="${TASKS_DIR%/}"
if [[ -z "$TASKS_DIR" ]]; then
    echo "Error: --tasks-dir must not be empty." >&2
    exit 1
fi

# Projects mount: sibling of the tasks mount (tasks -> projects,
# project/tasks -> project/projects). Mirrors task-env.sh's own derivation.
_parent="$(dirname "$TASKS_DIR")"
if [[ "$_parent" == "." ]]; then PROJECTS_REL="projects"; else PROJECTS_REL="$_parent/projects"; fi

if ! git -C "$TARGET" rev-parse --git-dir >/dev/null 2>&1; then
    echo "Note: $TARGET is not a git repo. The scripts will fall back to a"
    echo "      walk-up root search, which works, but 'git init' is recommended."
fi

MOUNT="$TARGET/$TASKS_DIR"
SCRIPTS_OUT="$MOUNT/scripts"
DOCS_OUT="$MOUNT/docs"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
created=(); updated=(); skipped=()

# render <src> <dst> — copy with GENERATOR-TIME placeholders substituted.
#
# TWO PLACEHOLDER NAMESPACES — do not conflate them:
#   generator-time : {{TASKS_REL}} {{DEFAULT_EPIC}} {{PROJECTS_REL}}
#                    {{PROJECTS_REL_LINE}}   -> substituted here, must not survive.
#   runtime        : {{NAME}} {{STATUS}} {{EPIC}} {{TAGS}} {{PRIORITY}}
#                    {{PARENT}} {{CREATED}} {{CATEGORY}}
#                    -> live in the task templates and MUST survive generation;
#                       the task-creation scripts substitute them per task.
# Never add a runtime token to the substitution list below — it would bake a
# fixed value into the template and silently break task creation.
render() {
    sed -e "s|{{TASKS_REL}}|$TASKS_DIR|g" \
        -e "s|{{DEFAULT_EPIC}}|$EPIC|g" \
        -e "s|{{PROJECTS_REL}}|$PROJECTS_REL|g" \
        "$1" > "$2"
}

# seed <src> <dst> [rendered] — CONTENT: write only if missing (unless --force)
seed() {
    local src="$1" dst="$2"
    if [[ -e "$dst" && "$FORCE" != true ]]; then
        skipped+=("${dst#$TARGET/}  (exists — preserved)")
        return 0
    fi
    [[ -e "$dst" ]] && updated+=("${dst#$TARGET/}  (re-seeded via --force)") || created+=("${dst#$TARGET/}")
    render "$src" "$dst"
}

echo "Generating task subsystem"
echo "  target : $TARGET"
echo "  mount  : $TASKS_DIR/"
echo "  epic   : $EPIC"
echo ""

# ---------------------------------------------------------------------------
# 1. MACHINERY — always overwritten
# ---------------------------------------------------------------------------
mkdir -p "$SCRIPTS_OUT" "$DOCS_OUT"

# core scripts
for f in "$SRC_DIR"/scripts/*; do
    base="$(basename "$f")"
    case "$base" in
        *.md) render "$f" "$SCRIPTS_OUT/$base" ;;   # e.g. list-tasks.md
        *)    cp "$f" "$SCRIPTS_OUT/$base" ;;
    esac
done

# templates live BESIDE the scripts (scripts reference "$SCRIPTS_DIR/*-template.md")
for f in "$SRC_DIR"/templates/*.md; do
    render "$f" "$SCRIPTS_OUT/$(basename "$f")"
done

# EMIT RULE: without the classes layer, strip the Category row from the
# user-task template so non-classes repos don't carry a dead field.
if [[ "$WITH_CLASSES" != true ]]; then
    perl -0pi -e 's{^\| Category[^\n]*\n}{}m' "$SCRIPTS_OUT/user-task-template.md"
fi

# generated config
PROJECTS_REL_LINE="# (projects layer not installed)"
if [[ "$WITH_PROJECTS" == true ]]; then
    PROJECTS_REL_LINE="PROJECTS_REL=\"$PROJECTS_REL\""
fi
sed -e "s|{{TASKS_REL}}|$TASKS_DIR|g" \
    -e "s|{{DEFAULT_EPIC}}|$EPIC|g" \
    -e "s|{{PROJECTS_REL_LINE}}|$PROJECTS_REL_LINE|g" \
    "$SRC_DIR/config/task-config.sh.in" > "$SCRIPTS_OUT/task-config.sh"

chmod +x "$SCRIPTS_OUT"/*.sh "$SCRIPTS_OUT"/*.py 2>/dev/null || true

# docs — USING.md is ALWAYS emitted (the skill is an accelerator, not the only copy)
render "$SRC_DIR/docs/USING.md"        "$DOCS_OUT/USING.md"
render "$SRC_DIR/docs/README.md"       "$DOCS_OUT/README.md"
render "$SRC_DIR/docs/task-manager.md" "$DOCS_OUT/task-manager.md"
updated+=("$TASKS_DIR/scripts/  (machinery: $(ls "$SCRIPTS_OUT" | wc -l | tr -d ' ') files)")
updated+=("$TASKS_DIR/docs/     (USING.md, README.md, task-manager.md)")

# ---------------------------------------------------------------------------
# 2. LAYERS
# ---------------------------------------------------------------------------
if [[ "$WITH_PROJECTS" == true ]]; then
    for f in "$SRC_DIR"/layers/projects/scripts/*.sh; do
        cp "$f" "$SCRIPTS_OUT/$(basename "$f")"; chmod +x "$SCRIPTS_OUT/$(basename "$f")"
    done
    updated+=("$TASKS_DIR/scripts/{new,list}-project*.sh  (projects layer)")
fi

if [[ "$WITH_GUARD" == true ]]; then
    cp "$SRC_DIR/layers/worktree-guard/check-task-complete.py" "$SCRIPTS_OUT/"
    chmod +x "$SCRIPTS_OUT/check-task-complete.py"
    updated+=("$TASKS_DIR/scripts/check-task-complete.py  (worktree guard)")
fi

# classes.md is CONTENT — the user edits it; never clobber their classes
if [[ "$WITH_CLASSES" == true ]]; then
    seed "$SRC_DIR/layers/classes/classes.md" "$MOUNT/classes.md"
fi

if [[ "$WITH_SKILL" == true ]]; then
    SKILL_OUT="$TARGET/.claude/skills/task-system"
    mkdir -p "$SKILL_OUT"
    render "$SRC_DIR/skill/task-system/SKILL.md" "$SKILL_OUT/SKILL.md"
    updated+=(".claude/skills/task-system/SKILL.md  (on-demand skill)")
fi

# ---------------------------------------------------------------------------
# 3. CONTENT — starter epic (created only if missing)
# ---------------------------------------------------------------------------
if [[ -d "$MOUNT/$EPIC" ]]; then
    skipped+=("$TASKS_DIR/$EPIC/  (epic exists — task content preserved)")
else
    ( cd "$TARGET" && "$SCRIPTS_OUT/new-epic.sh" --name "$EPIC" >/dev/null )
    created+=("$TASKS_DIR/$EPIC/{inbox,draft,backlog,in-progress,complete,wont-do}/")
fi

# ---------------------------------------------------------------------------
# 4. CLAUDE.md kernel snippet
# ---------------------------------------------------------------------------
SNIPPET="$(render "$SRC_DIR/snippets/claude-md.snippet.md" /dev/stdout)"
if [[ "$INJECT_CLAUDE_MD" == true ]]; then
    CMD_FILE="$TARGET/CLAUDE.md"
    if [[ -f "$CMD_FILE" ]] && grep -q "^## Task tracking" "$CMD_FILE"; then
        skipped+=("CLAUDE.md  (already has a '## Task tracking' section)")
    else
        printf '\n%s\n' "$SNIPPET" >> "$CMD_FILE"
        updated+=("CLAUDE.md  (kernel snippet appended)")
    fi
fi

# ---------------------------------------------------------------------------
# 5. Summary
# ---------------------------------------------------------------------------
echo "Created:"; for i in "${created[@]:-}";  do [[ -n "$i" ]] && echo "  + $i"; done
echo "Written:"; for i in "${updated[@]:-}";  do [[ -n "$i" ]] && echo "  ~ $i"; done
if [[ ${#skipped[@]} -gt 0 ]]; then
    echo "Preserved:"; for i in "${skipped[@]:-}"; do [[ -n "$i" ]] && echo "  = $i"; done
fi

echo ""
echo "Layers: classes=$WITH_CLASSES projects=$WITH_PROJECTS guard=$WITH_GUARD skill=$WITH_SKILL"
echo ""
echo "Next:"
echo "  $TASKS_DIR/scripts/new-user-task.sh --folder draft --name my-first-task"
echo "  $TASKS_DIR/scripts/list-tasks.sh --folder draft --depth 2"
echo "  Docs: $TASKS_DIR/docs/USING.md"
if [[ "$WITH_GUARD" == true ]]; then
    echo ""
    echo "  Worktree guard — note the first argument is the EPIC dir, not the mount:"
    echo "    python3 $TASKS_DIR/scripts/check-task-complete.py $TASKS_DIR/$EPIC <branch>"
fi
if [[ "$INJECT_CLAUDE_MD" != true ]]; then
    echo ""
    echo "--- add this to the target's CLAUDE.md (or GEMINI.md — it is agent-neutral) ---"
    echo "$SNIPPET"
    echo "--- end snippet ---"
fi
