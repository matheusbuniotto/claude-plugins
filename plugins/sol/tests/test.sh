#!/usr/bin/env bash
# Plain-bash tests for the sol hooks. usage: tests/test.sh
cd "$(dirname "$0")/.." || exit 1
H=skills/sol/hook.sh; RUN=skills/sol/run.sh; fail=0
T=$(mktemp -d); export TMPDIR=$T; cd "$T" || exit 1; mkdir -p .sol; cd - >/dev/null
ok() { echo "ok   $1"; }; bad() { echo "FAIL $1"; fail=1; }
chk() { # name, expected-substring, actual
  case "$3" in *"$2"*) ok "$1";; *) bad "$1 (got: ${3:0:120})";; esac; }
j() { printf '{"cwd":"%s","session_id":"t","agent_id":"a"%s}' "$T" "${1:+,$1}"; }

chk "style injected at session start" "sol style" "$(j '"hook_event_name":"SessionStart"' | $H start)"
echo "custom style X" > "$T/.sol/STYLE"
chk "STYLE override" "custom style X" "$(j '' | $H start)"; rm "$T/.sol/STYLE"
chk "REVIEW directive" "sol REVIEW on" "$( echo mode=draft > "$T/.sol/REVIEW"; j '' | $H start)"
chk "reviewer cannot approve in draft" "deny" "$(j '"agent_type":"sol-reviewer","tool_name":"Bash","tool_input":{"command":"gh pr review 1 --approve"}' | $H guard)"
echo mode=post > "$T/.sol/REVIEW"
[ -z "$(j '"agent_type":"sol-reviewer","tool_name":"Bash","tool_input":{"command":"gh pr review 1 --comment"}' | $H guard)" ] && ok "post allowed (no deny)" || bad "post allowed"
chk "researcher write outside .sol denied" "deny" "$(j '"agent_type":"sol-researcher","tool_name":"Write","tool_input":{"file_path":"/x/y.md"}' | $H guard)"
[ -z "$(j '"agent_type":"sol-coder","tool_name":"Write","tool_input":{"file_path":"/x/y.md"}' | $H guard)" ] && ok "coder unrestricted" || bad "coder unrestricted"
for i in 1 2 3 4; do mkdir -p "$T/.sol/r$i"; j "\"tool_input\":{\"subagent_type\":\"sol-coder\",\"prompt\":\"use .sol/r$i\"}" | $H pre >/dev/null; done
chk "parallel cap" "already running" "$(mkdir -p $T/.sol/r5; j '"tool_input":{"subagent_type":"sol-coder","prompt":"use .sol/r5"}' | $H pre)"
echo 3 > "$T/.sol/PRO"; (cd "$T" && "$OLDPWD/skills/sol/stop.sh" >/dev/null); [ ! -f "$T/.sol/PRO" ] && ok "stop.sh ends pro mode" || bad "stop.sh"
[ -z "$(j '"tool_input":{"subagent_type":"sol-coder","prompt":"use .sol/r6"}' | $H pre)" ] && ok "slots freed by stop.sh" || bad "slots freed"

# fail-open on a broken hook
B=$(mktemp -d); cp skills/sol/*.sh "$B"; echo "(((" >> "$B/hook.sh"
out=$(echo '{}' | "$B/run.sh" guard 2>&1); rc=$?
[ $rc -eq 0 ] && chk "fail-open message" "syntax error" "$out" || bad "fail-open exit code $rc"
rm -rf "$T" "$B"; exit $fail
