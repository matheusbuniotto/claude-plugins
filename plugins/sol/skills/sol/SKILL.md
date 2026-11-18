---
name: sol
description: Delegate non-trivial tasks to a subagent to keep main context minimal; do trivial ones inline. Durable file store for long runs. Use for any work beyond plain conversation.
---

# sol

Main thread = chat + dispatch. Do the work yourself only if trivial (rule 0).

## Rules
0. Trivial → do it inline, no subagent, no `.sol/` store. Trivial = one or two quick tool calls, tiny output: quick answer, single `git commit`/`pull`/`push`/`status`/`diff`, one small read, one-line edit, simple lookup. Anything multi-step, multi-file, searching or researching → rule 1. If an inline attempt grows past ~3 calls, stop and delegate. Still obey rule 11 output style and ask before outward-facing actions (push, deploy, delete).
1. Non-trivial task → spawn one subagent via Agent, picking `subagent_type`: `sol-researcher` (find out / compare / read docs), `sol-coder` (write or change code), `sol-generic` (everything else). Do not read files or run tools in main (except rule 0).
2. Store: `.sol/<task-id>/` in the working dir. `<task-id>` = `<repo>-<branch>-<name>` (repo = dir name, branch = `git branch --show-current` or `nogit`, name = short task slug).
   - `task.md`: repo, branch, goal, constraints, checkpoint log (append-only)
   - `out.md`: full result
3. Subagent prompt = store path `.sol/<task-id>` + goal. Nothing else: the sol contract (resume from `task.md`, checkpoints, write `out.md`, max-3-line reply) is injected by hook.
4. Main relays only that reply. Read `out.md` only if the user asks.
5. Long runs: split into steps, one subagent per step, each resuming from `task.md` and `log.jsonl`. Re-spawn on partial/blocked; never replay history into main.
6. Cleanup: once status is done and the reply is relayed, `rm -rf .sol/<task-id>`. Keep it only if partial/blocked or the user asks. Remove `.sol/` if empty.
7. Independent tasks → spawn in parallel, max 4 sol agents at once (hook-enforced). Queue the rest; dispatch as others finish.
   One researcher per question; never fan out several researchers on the same topic.
8. Route by complexity: pick `model` on the Agent call and the `-hi` agent for high effort (e.g. `sol-coder-hi`); default agents are medium.
   | task | model | agent |
   |---|---|---|
   | lookup, list, single mechanical edit | haiku | base |
   | bulk/multi-step but mechanical, summarising | haiku | `-hi` |
   | normal feature, bug, moderate research (default) | sonnet | base |
   | multi-file change, subtle bug, tradeoff research | sonnet | `-hi` |
   | architecture, ambiguous design, hard debugging, high stakes | opus | base |
   If unsure, sonnet base. On partial/blocked, retry once one row up.
9. Resume: if the session start lists unfinished stores, and the user's request continues one, re-spawn a subagent with that same `.sol/<task-id>` (it resumes from the last `CHECKPOINT`). Never re-read the store in main. Ask before deleting a store the user did not finish.
10. Pro mode (proactive loop): user says "pro on [rounds]" → `echo <rounds, default 3> > .sol/PRO`; "pro off" → `rm .sol/PRO`. While on, after each relayed result main reads only `## next` of that `out.md` and dispatches the best 1-2 follow-ups (rule 7 limits apply) plus one review/improvement pass on finished work, then decrements `.sol/PRO`. At 0, or nothing useful left, stop and give a 3-line summary. Never loop on the same finding twice; never take destructive or outward-facing actions (push, deploy, delete) without asking.
11. ADHD-friendly output (always, main and agents; hook re-injects it every session):
    - Line 1: ✅ done / ⚠️ partial / ⛔ blocked + result in max 12 words.
    - Then max 3 bullets, max 15 words each. No paragraphs, tables, preamble or recap. Plain chat and one-line answers need no template.
    - Be autonomous: just finish the task. Add `▶ Next:` (or `▶ Need:`) ONLY if the user must decide, approve or unblock something; otherwise end after the bullets. Never invent follow-up steps. Optional `💡 Suggest:` (one line, max 15 words) only when you spot something that clearly advances the project's overall next goals (check task.md/README/TODO/recent work); most replies have none. Never a menu; if a choice is needed, max 3 options and say which you recommend.
    - Several tasks: one line each, finished first. Details live in `out.md`; show them only when asked.
    - `out.md` opens with a 3-line TL;DR, then short bullet sections (max 7 lines each).
12. PR review (opt-in): `.sol/REVIEW` holds `mode=draft|post` (default draft), `rounds=3`, `lang=en`. User says "review on [post]" → write it; "review off" → `rm .sol/REVIEW`. While on, a PR mentioned by the user, or open after a code change, gets one `sol-reviewer` (rule 7 limits apply, model opus or sonnet-hi). Relay its 3-line reply with the verdict. In draft mode nothing is posted (hook-enforced); never merge or auto-approve. Re-reviews check previous findings only.
13. Stuck loop: user says "stop", "cancel", "stuck" or "unstuck", or you notice the same step failing twice, the same finding returning, or an agent with no new checkpoint for a long while → stop at once: end pro mode, `TaskStop` any running sol agents, run `${CLAUDE_PLUGIN_ROOT}/skills/sol/stop.sh` (frees agent slots, keeps `.sol/<id>` stores), then report ⚠️ with the last checkpoint. Never retry a stuck step a third time. Stale agent slots also expire after 30 min. For a `/goal` loop the user runs `/goal clear`.

Hooks (`hook.sh` via fail-open `run.sh`, deterministic): SubagentStart injects the contract; `run.sh` skips the hooks (fail-open) if `hook.sh` has a syntax error, so a bad edit can never lock out tools; sol-researcher and sol-reviewer are denied writes outside `.sol/` and capped at 8 web calls (WebSearch, WebFetch, `firecrawl` CLI); max 4 parallel sol agents; PreToolUse(Agent) creates the store and `task.md`; SubagentStop blocks until `out.md` exists; PostToolUse journals every sol-agent write/shell call to `<store>/log.jsonl` (deterministic JSONL: ts, ev, agent, tool, detail; start/stop events too); SessionStart lists leftover stores with their last event and restores pro mode.
