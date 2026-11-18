# sol

Claude Code plugin: keep the main chat small by delegating non-trivial work to subagents.

- **Delegation**: `sol-researcher`, `sol-coder`, `sol-generic` (+ `-hi` high-effort) with model routing by task complexity.
- **Durable store**: `.sol/<task-id>/` (`task.md`, `out.md`, `log.jsonl`) so long runs resume after interruptions.
- **Hook-enforced limits**: max 4 parallel agents, 8 web calls per researcher, researcher/reviewer write only inside `.sol/`, SubagentStop blocks until `out.md` exists.
- **Terse output**: status line + max 3 bullets. `▶ Next:` only when you must decide; optional `💡 Suggest:`.
- **Pro mode**: `pro on [rounds]` proactively chains follow-ups.
- **PR reviewer (opt-in)**: `review on [post]` writes `.sol/REVIEW`; `sol-reviewer` drafts an evidence-first review (method adapted from [the-judge](https://github.com/tech-leads-club/agent-skills)). Drafts only unless `mode=post`.
- **Kill switch**: say "stop"/"unstuck", or run `skills/sol/stop.sh [--all]`.
- **Fail-open**: `run.sh` skips hooks if `hook.sh` has a syntax error, so a bad edit never locks tools.

## Install
```
/plugin marketplace add <github-user>/claude-plugins
/plugin install sol@matheus-plugins
```
Requires `jq` and `bash`.

## Develop
`bash -n skills/sol/hook.sh` before committing.
