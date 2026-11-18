#!/usr/bin/env bash
# sol hooks. Only act on sol-dispatched agents (prompt/transcript mentions .sol/<id>).
# usage: hook.sh pre|stop|start|contract|guard|web   (hook JSON on stdin)
STYLE='sol style (ADHD-friendly, always): line 1 = ✅ done / ⚠️ partial / ⛔ blocked + the result in max 12 words. Then max 3 bullets, max 15 words each. Add a single "▶ Next:" line ONLY when something truly needs the user (a decision, approval, or blocker); otherwise end after the bullets - be autonomous, never invent follow-ups. If you notice something that clearly serves the overall project next goals, add at most one "💡 Suggest:" line (max 15 words); skip it when nothing stands out. Never a menu. No paragraphs, no tables, no preamble, no recap. Details only if asked. One-line answers and plain chat need no template.'
MAX_PAR=${SOL_MAX_PAR:-4}   # parallel sol agents
MAX_WEB=${SOL_MAX_WEB:-8}   # WebSearch+WebFetch calls per researcher
in=$(cat)
j() { jq -r "$1 // empty" <<<"$in"; }
cwd=$(j .cwd); cd "${cwd:-.}" 2>/dev/null || exit 0
S="${TMPDIR:-/tmp}/sol-state/$(j .session_id)"; mkdir -p "$S/run" "$S/web" "$S/own"
ev() { # append one deterministic JSONL event to the agent's store log
  local id; id=$(cat "$S/own/$(j .agent_id)" 2>/dev/null) || return 0; [ -d ".sol/$id" ] || return 0
  jq -nc --arg ts "$(date -u +%FT%TZ)" --arg ev "$1" --arg a "$(j .agent_type)" --arg t "$(j .tool_name)" --arg d "${2:-}" \
    '{ts:$ts,ev:$ev,agent:$a} + (if $t != "" then {tool:$t} else {} end) + (if $d != "" then {detail:$d[0:200]} else {} end)' >> ".sol/$id/log.jsonl"
}
deny() { jq -nc --arg r "$1" '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$r}}'; exit 0; }
case "$1" in
contract) # SubagentStart: claim the oldest unclaimed dispatched store, log, inject the sol contract
  for r in $(ls -tr "$S/run" 2>/dev/null); do   # mkdir is atomic: concurrent starts can't claim the same store
    [ -d ".sol/$r" ] && mkdir "$S/claim.$r" 2>/dev/null && { echo "$r" > "$S/own/$(j .agent_id)"; break; }
  done
  ev start
  jq -nc --arg c "sol contract: the prompt gives a store \`.sol/<id>\`. Read its task.md first and resume from the last checkpoint. Append a \`CHECKPOINT n: ...\` line after each step. Write the full result to <store>/out.md; if pro mode is on (.sol/PRO exists) end it with a \`## next\` section: up to 3 concrete follow-up tasks, one line each. out.md starts with a 3-line TL;DR, then short bullet sections (no section over 7 lines, bold the key terms, no walls of text). Final reply: max 3 lines - status emoji (✅/⚠️/⛔), one-line result of max 12 words, path. Researchers: at most $MAX_WEB web calls; stop as soon as the answer is supported." '{hookSpecificOutput:{hookEventName:"SubagentStart",additionalContext:$c}}'
  ;;
guard) # PreToolUse(Write|Edit|Bash): sol-researcher may only write inside .sol/
  case "$(j .agent_type)" in sol-researcher|sol-researcher-hi|sol-reviewer) ;; *) exit 0;; esac
  if [ "$(j .tool_name)" = Bash ]; then
    if [ "$(j .agent_type)" = sol-reviewer ] && grep -qE 'gh +(pr +(review|comment|merge|close|edit)|api .*(reviews|comments))' <<<"$(j .tool_input.command)"; then
      grep -qs '^mode=post' .sol/REVIEW || deny "sol-reviewer drafts only: write the review to out.md. Posting needs mode=post in .sol/REVIEW."
    fi
    c=$(j .tool_input.command | sed -E 's/[0-9&]?>+ ?(&[0-9]|\/dev\/null)//g')
    grep -qE '(>|\btee\b|\brm\b|\bmv\b|\bcp\b|\bsed +-i|\bgit +(commit|push|checkout|reset)|\binstall\b)' <<<"$c" && ! grep -q '\.sol/' <<<"$c" && deny "sol-researcher is read-only: shell writes must target .sol/"
    exit 0
  fi
  case "$(j .tool_input.file_path)" in */.sol/*) ;; *) deny "sol-researcher may only write inside .sol/";; esac
  ;;
log) # PostToolUse(Write|Edit|Bash): journal every mutating tool call of sol agents
  case "$(j .agent_type)" in sol-*) ;; *) exit 0;; esac
  ev tool "$(j '.tool_input.file_path // .tool_input.command')"
  ;;
web) # PreToolUse(WebSearch|WebFetch): cap per researcher
  case "$(j .agent_type)" in sol-researcher|sol-researcher-hi) ;; *) exit 0;; esac
  f="$S/web/$(j .agent_id)"; n=$(( $(cat "$f" 2>/dev/null || echo 0) + 1 )); echo $n > "$f"
  [ "$n" -gt "$MAX_WEB" ] && deny "web budget spent ($MAX_WEB calls). Write out.md from what you have; mark gaps as uncertain."
  ;;
pre) # PreToolUse(Agent): cap parallel sol agents, create store + task.md
  case "$(j .tool_input.subagent_type)" in sol-*) ;; *) exit 0;; esac
  find "$S/run" -type f -mmin +30 -delete 2>/dev/null
  [ "$(ls "$S/run" | wc -l)" -ge "$MAX_PAR" ] && deny "$MAX_PAR sol agents already running. Wait for one to finish, or if stuck run $(dirname "$0")/stop.sh to free the slots."
  id=$(grep -oE '\.sol/[A-Za-z0-9._-]*[A-Za-z0-9_]' <<<"$(j .tool_input.prompt)" | head -1)
  [ -z "$id" ] && exit 0
  touch "$S/run/${id#.sol/}"   # register at dispatch so parallel dispatches see each other
  mkdir -p "$id"
  [ -f "$id/task.md" ] || printf 'repo: %s\nbranch: %s\ncreated: %s\ngoal: %s\n' "$(basename "$PWD")" \
    "$(git branch --show-current 2>/dev/null || echo nogit)" "$(date -u +%FT%TZ)" "$(j .tool_input.description)" > "$id/task.md"
  ;;
stop) # SubagentStop: block until out.md exists, then unregister
  t=$(j .agent_transcript_path); id=$([ -f "$t" ] && grep -oE '\.sol/[A-Za-z0-9._-]*[A-Za-z0-9_]' "$t" | head -1)
  done_() { ev stop; rmdir "$S/claim.${id#.sol/}" 2>/dev/null; rm -f "$S/web/$(j .agent_id)" "$S/run/${id#.sol/}"; exit 0; }
  [ "$(j .stop_hook_active)" = true ] && done_
  if [ -n "$id" ] && [ ! -f "$id/out.md" ]; then
    jq -nc --arg r "sol: write full result to $PWD/$id/out.md (keep the .sol/ segment), append a checkpoint to $id/task.md, then reply in max 3 lines." '{decision:"block",reason:$r}'
  else done_; fi
  ;;
start) # SessionStart: list leftover stores; add the pro-mode directive when .sol/PRO exists
  c="$STYLE"; [ -s .sol/STYLE ] && c=$(cat .sol/STYLE)   # per-project override of the output style
  [ -f .sol/PRO ] && c="$c
sol PRO mode on ($(cat .sol/PRO) rounds left). After relaying each result, read only its out.md '## next' and dispatch the best 1-2 follow-ups, plus one review/improvement pass on finished work; decrement .sol/PRO each round, stop at 0 or when nothing useful remains, then give the user a 3-line summary. Never loop on the same finding twice."
  [ -f .sol/REVIEW ] && c="$c
sol REVIEW on ($(tr '\n' ' ' < .sol/REVIEW)). When the user mentions a PR, or after you finish a code change that has an open PR, dispatch one sol-reviewer on it (rule 12). Relay only its 3-line reply; never post unless mode=post."
  l=$(for d in .sol/*/; do [ -d "$d" ] && echo "${d%/} | $(tail -1 "$d/log.jsonl" 2>/dev/null || tail -1 "$d/task.md" 2>/dev/null)"; done)
  [ -n "$l" ] && c="$c
sol: unfinished tasks (resume via task.md or rm):
$l"
  [ -z "$c" ] || jq -nc --arg c "$c" '{hookSpecificOutput:{hookEventName:"SessionStart",additionalContext:$c}}'
  ;;
esac
exit 0
