#!/usr/bin/env bash
# self-test.sh — end-to-end self test for the task-subsystem generator.
#
# Generates into disposable repos under sandbox/, exercises the emitted
# subsystem, verifies regeneration safety, then tears everything down.
#
# Usage:
#   bash self-test.sh            # run and clean up
#   bash self-test.sh --keep     # leave sandbox/ in place for inspection
#
# Exit code is the number of failed assertions (0 = all green), so it is
# CI-ready as-is.

set -u

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GEN="$REPO/generate.sh"
SANDBOX="$REPO/sandbox"
KEEP=false
[[ "${1:-}" == "--keep" ]] && KEEP=true

PASS=0; FAIL=0; FAILED_LABELS=()
ok(){  printf '    \033[32m✓\033[0m %s\n' "$1"; PASS=$((PASS+1)); }
bad(){ printf '    \033[31m✗\033[0m %s\n' "$1"; FAIL=$((FAIL+1)); FAILED_LABELS+=("$1"); }
t(){ if [[ $1 == 0 ]]; then ok "$2"; else bad "$2"; fi; }
section(){ printf '\n\033[1m%s\033[0m\n' "$1"; }

cleanup(){
    if [[ "$KEEP" == true ]]; then
        echo ""; echo "sandbox/ kept at: $SANDBOX"
    else
        rm -rf "$SANDBOX"
    fi
}
trap cleanup EXIT

rm -rf "$SANDBOX"; mkdir -p "$SANDBOX"

newrepo(){ rm -rf "$1"; mkdir -p "$1"; ( cd "$1" && git init -q \
    && git config user.email selftest@local && git config user.name selftest ); }

# Exercise the full task lifecycle against a generated subsystem.
# $1 = target root, $2 = mount, $3 = epic, $4 = label prefix
lifecycle(){
    local T="$1" REL="$2" EP="$3" TAG="$4"
    local S="$T/$REL/scripts"
    ( cd "$T" && "$S/new-user-task.sh" --epic "$EP" --folder draft --name demo >/dev/null 2>&1 )
    local TASK; TASK="$(ls "$T/$REL/$EP/draft" 2>/dev/null | grep -- '-demo$' | head -1)"
    [[ -n "$TASK" ]]; t $? "$TAG create task"
    [[ -z "$TASK" ]] && return 1
    local SHORT="${TASK%%-*}"
    ( cd "$T" && "$S/new-user-subtask.sh" --epic "$EP" --folder draft --parent "$TASK" --name step-one >/dev/null 2>&1 )
    [[ -d "$T/$REL/$EP/draft/$TASK/$SHORT-0000-step-one" ]]; t $? "$TAG nest subtask (NNNN=0000)"
    local OUT; OUT="$( cd "$T" && "$S/list-tasks.sh" --epic "$EP" --folder draft --depth 2 2>&1 )"
    [[ "$OUT" == *demo* && "$OUT" == *step-one* ]]; t $? "$TAG list renders task + subtask"
    ( cd "$T" && "$S/complete-task.sh" --epic "$EP" --folder draft --parent "$TASK" --name "$SHORT-0000-step-one" >/dev/null 2>&1 )
    [[ -d "$T/$REL/$EP/draft/$TASK/X-$SHORT-0000-step-one" ]]; t $? "$TAG complete subtask -> X- rename"
    grep -q '^- \[x\]' "$T/$REL/$EP/draft/$TASK/README.md"; t $? "$TAG parent checkbox -> [x]"
    ( cd "$T" && "$S/move-task.sh" --epic "$EP" --name "$TASK" --from draft --to in-progress >/dev/null 2>&1 )
    [[ -d "$T/$REL/$EP/in-progress/$TASK" ]]; t $? "$TAG move draft -> in-progress"
    ( cd "$T" && "$S/complete-task.sh" --epic "$EP" --folder in-progress --name "$TASK" >/dev/null 2>&1 )
    [[ -d "$T/$REL/$EP/complete/$TASK" ]]; t $? "$TAG complete task -> complete/"
}

echo "Task-subsystem generator — self test"
echo "sandbox: $SANDBOX"

############################################################
section "1. Core generation (mount=tasks, no layers)"
A="$SANDBOX/core"; newrepo "$A"
"$GEN" --target-repo "$A" --tasks-dir tasks --epic main >/dev/null 2>&1
t $? "generate.sh exits 0"
[[ -f "$A/tasks/scripts/task-config.sh" ]];        t $? "task-config.sh rendered"
[[ -f "$A/tasks/docs/USING.md" ]];                 t $? "USING.md always emitted"
[[ -d "$A/tasks/main/backlog" ]];                  t $? "starter epic scaffolded"
[[ ! -f "$A/tasks/classes.md" ]];                  t $? "no classes.md without flag"
[[ ! -d "$A/.claude/skills" ]];                    t $? "no skill without flag"
! grep -qE '^\| Category' "$A/tasks/scripts/user-task-template.md"; t $? "Category row stripped (classes off)"
lifecycle "$A" tasks main "lifecycle:"

############################################################
section "2. Decoupling checks (the whole point of the extraction)"
LEAK=$(grep -rl 'project/tasks' "$A/tasks/scripts" 2>/dev/null | wc -l | tr -d ' ')
[[ "$LEAK" == "0" ]];                              t $? "zero 'project/tasks' literals in emitted scripts"
LEAK=$(grep -rl '\.\./\.\./\.\.' "$A/tasks/scripts" 2>/dev/null | wc -l | tr -d ' ')
[[ "$LEAK" == "0" ]];                              t $? "zero '../../..' root walks in emitted scripts"
GENPH=$(grep -rl '{{TASKS_REL}}\|{{DEFAULT_EPIC}}\|{{PROJECTS_REL}}\|{{PROJECTS_REL_LINE}}\|{{STATUS_REL}}\|{{CONTAINER_REL}}\|{{TASKS_BASE}}' "$A/tasks" 2>/dev/null | wc -l | tr -d ' ')
[[ "$GENPH" == "0" ]];                             t $? "generator-time placeholders fully rendered"
grep -q '{{NAME}}' "$A/tasks/scripts/user-task-template.md"; t $? "runtime placeholders survive in templates"

############################################################
section "3. All layers (nested mount, custom epic)"
B="$SANDBOX/layers"; newrepo "$B"
"$GEN" --target-repo "$B" --tasks-dir pm/tasks --epic dev \
    --with-classes --with-projects --with-status --with-worktree-guard --with-skill >/dev/null 2>&1
[[ -f "$B/pm/tasks/classes.md" ]];                     t $? "classes layer emitted"
[[ -f "$B/pm/tasks/scripts/new-project.sh" ]];         t $? "projects layer emitted"
[[ -f "$B/pm/tasks/scripts/check-task-complete.py" ]]; t $? "worktree-guard emitted"
[[ -f "$B/.claude/skills/task-system/SKILL.md" ]];     t $? "skill emitted to .claude/skills/"
grep -q 'PROJECTS_REL="pm/projects"' "$B/pm/tasks/scripts/task-config.sh"; t $? "PROJECTS_REL derived (pm/tasks -> pm/projects)"
# status layer: sibling status/ + container README (pm/ workspace)
[[ -f "$B/pm/status/README.md" ]];                     t $? "status layer emitted (pm/status, sibling of tasks)"
[[ -f "$B/pm/README.md" ]];                            t $? "container README emitted (pm/ workspace)"
grep -q 'pm/tasks/docs/USING.md' "$B/pm/README.md";    t $? "container README points at tasks docs"
grep -q 'pm/tasks/docs/USING.md' "$B/pm/status/README.md"; t $? "status README points at the workflow in USING.md"
grep -q 'Status reports' "$B/pm/tasks/docs/USING.md";  t $? "USING.md carries the status-report workflow"
STLEAK=$(grep -rl '{{STATUS_REL}}\|{{CONTAINER_REL}}\|{{TASKS_BASE}}' "$B/pm" 2>/dev/null | wc -l | tr -d ' ')
[[ "$STLEAK" == "0" ]];                                t $? "status placeholders fully rendered"
grep -qE '^\| Category' "$B/pm/tasks/scripts/user-task-template.md"; t $? "Category row present (classes on)"
lifecycle "$B" pm/tasks dev "nested:"
( cd "$B" && "$B/pm/tasks/scripts/new-project.sh" --name svc >/dev/null 2>&1 )
[[ -d "$B/pm/projects/svc" ]];                         t $? "new-project.sh writes to derived mount"
# guard: first arg is the EPIC dir, not the mount
( cd "$B" && python3 "$B/pm/tasks/scripts/check-task-complete.py" "pm/tasks/dev" demo >/dev/null 2>&1 )
[[ $? -eq 0 ]];                                        t $? "worktree-guard passes for a completed task"

############################################################
section "4. Regeneration safety (upgrade path)"
C="$SANDBOX/regen"; newrepo "$C"
"$GEN" --target-repo "$C" --tasks-dir tasks --epic main --with-classes >/dev/null 2>&1
( cd "$C" && "$C/tasks/scripts/new-user-task.sh" --folder draft --name keep-me --category general >/dev/null 2>&1 )
TC="$(ls "$C/tasks/main/draft" | grep -- '-keep-me$' | head -1)"
echo "MY LOCAL EDIT" >> "$C/tasks/classes.md"
BEFORE_TASK="$(cat "$C/tasks/main/draft/$TC/README.md")"
BEFORE_CLASSES="$(cat "$C/tasks/classes.md")"
BEFORE_STATUS="$(cat "$C/tasks/main/draft/README.md")"
( cd "$C" && git add -A >/dev/null 2>&1 && git commit -qm baseline >/dev/null 2>&1 )

"$GEN" --target-repo "$C" --tasks-dir tasks --epic main --with-classes >/dev/null 2>&1
[[ "$(cat "$C/tasks/main/draft/$TC/README.md")" == "$BEFORE_TASK" ]];  t $? "task content untouched"
[[ "$(cat "$C/tasks/classes.md")" == "$BEFORE_CLASSES" ]];             t $? "user-edited classes.md preserved"
[[ "$(cat "$C/tasks/main/draft/README.md")" == "$BEFORE_STATUS" ]];    t $? "status task list not clobbered"
DIRTY="$(git -C "$C" status --porcelain | wc -l | tr -d ' ')"
[[ "$DIRTY" == "0" ]];                                                 t $? "identical re-run -> zero-line git diff"
echo "# local hack" >> "$C/tasks/scripts/show-task.sh"
"$GEN" --target-repo "$C" --tasks-dir tasks --epic main --with-classes >/dev/null 2>&1
! grep -q "local hack" "$C/tasks/scripts/show-task.sh";                t $? "machinery IS upgraded (local edit reverted)"
"$GEN" --target-repo "$C" --tasks-dir tasks --epic main --with-classes --with-projects >/dev/null 2>&1
[[ -f "$C/tasks/scripts/new-project.sh" ]];                            t $? "layer added to existing install"
[[ "$(cat "$C/tasks/main/draft/$TC/README.md")" == "$BEFORE_TASK" ]];  t $? "...task content still untouched"

############################################################
section "5. Git worktree layout (.bare + linked worktree)"
W="$SANDBOX/wt"; rm -rf "$W"; mkdir -p "$W"
( cd "$W" && mkdir mainwt && cd mainwt && git init -q \
  && git config user.email selftest@local && git config user.name selftest \
  && echo seed > seed.txt && git add -A && git commit -qm seed \
  && git worktree add -q ../linked ) >/dev/null 2>&1
"$GEN" --target-repo "$W/linked" --tasks-dir tasks --epic main >/dev/null 2>&1
t $? "generates into a linked worktree"
[[ -f "$W/linked/.git" ]];                 t $? "linked worktree .git is a FILE (not a dir)"
ROOT="$( cd "$W/linked/tasks/scripts" && bash -c 'SCRIPTS_DIR="$(pwd)"; source ./task-env.sh; echo "$REPO_ROOT"' 2>/dev/null )"
[[ "$ROOT" == "$W/linked" ]];              t $? "root resolves to worktree root, not .bare container"
lifecycle "$W/linked" tasks main "worktree:"

############################################################
section "6. CLAUDE.md kernel"
D="$SANDBOX/kernel"; newrepo "$D"; printf '# Existing\n\nhouse rules\n' > "$D/CLAUDE.md"
"$GEN" --target-repo "$D" --inject-claude-md >/dev/null 2>&1
grep -q '## Task tracking' "$D/CLAUDE.md";  t $? "kernel appended"
grep -q 'house rules' "$D/CLAUDE.md";       t $? "existing content preserved"
L1=$(wc -l < "$D/CLAUDE.md")
"$GEN" --target-repo "$D" --inject-claude-md >/dev/null 2>&1
[[ "$L1" == "$(wc -l < "$D/CLAUDE.md")" ]]; t $? "re-inject idempotent (no duplicate section)"
KL=$(grep -c . "$D/CLAUDE.md")
[[ $KL -lt 25 ]];                           t $? "always-on cost stays small ($KL non-blank lines)"

############################################################
section "7. Golden reproducibility (tests/run.sh)"
bash "$REPO/tests/run.sh" >/dev/null 2>&1
t $? "generated output matches checked-in golden fixtures"

############################################################
printf '\n\033[1m%s\033[0m\n' "==============================================="
if [[ $FAIL -eq 0 ]]; then
    printf '\033[32mALL GREEN\033[0m — %d assertions passed\n' "$PASS"
else
    printf '\033[31m%d FAILED\033[0m / %d total\n' "$FAIL" "$((PASS+FAIL))"
    for l in "${FAILED_LABELS[@]}"; do echo "  ✗ $l"; done
fi
exit $FAIL
