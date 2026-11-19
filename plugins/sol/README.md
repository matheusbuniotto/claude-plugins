# sol

Claude Code plugin that keeps the main chat small: non-trivial work goes to subagents, results live in a durable `.sol/` store, replies stay short.

## Install
```
/plugin install sol --marketplace matheusbuniotto/claude-plugins
```
Requires `bash` and `jq`. If `jq` is missing the hooks disable themselves and say so; nothing breaks.

## What you get
| piece | what it does |
|---|---|
| agents | `sol-researcher`, `sol-coder`, `sol-generic`, each with a `-hi` high-effort variant; `sol-reviewer`; `planner` (plan, TDD, analytical design doc) |
| store | `.sol/<task-id>/` with `task.md`, `out.md`, `log.jsonl`; long runs resume after interruptions |
| hook limits | max 4 parallel agents, 8 web calls per researcher, researcher and reviewer write only in `.sol/` |
| terse output | status line + max 3 bullets; `▶ Next:` only when you must decide |
| pro mode | `/sol:pro [rounds]` chains follow-ups, stops at 0 |
| PR reviewer | `/sol:review on [post]`; evidence-first draft review, nothing posted unless `mode=post` |
| visual explainer | `visual-explainer` skill: big-picture ELI10 HTML pages and visual design docs |
| kill switch | `/sol:stop` (or say "stop"); frees agent slots, keeps stores |

## Configure (per project, all optional)
- `.sol/STYLE`: replace the default output-style text injected at session start.
- `.sol/REVIEW`: `mode=draft|post`, `rounds=3`, `lang=en`.
- Env: `SOL_MAX_PAR` (default 4), `SOL_MAX_WEB` (default 8).
- Add `.sol/` to your `.gitignore`.

## Troubleshooting
- Hooks seem inactive: `claude --debug`; look for `sol:` lines. Missing `jq` or a syntax error in `hook.sh` prints a one-line warning.
- "4 sol agents already running": run `/sol:stop`.
- Reviewer will not post: set `mode=post` in `.sol/REVIEW` on purpose.

## Develop
`bash plugins/sol/tests/test.sh`, then `claude plugin validate .`. The reviewer method is adapted from [the-judge](https://github.com/tech-leads-club/agent-skills).

MIT licensed.
