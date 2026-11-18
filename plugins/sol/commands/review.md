---
description: Turn the opt-in sol PR reviewer on or off (/sol:review on [post] | off | status)
argument-hint: on [post] | off | status
---
Argument: `$ARGUMENTS`.
- `on` → `mkdir -p .sol && printf 'mode=draft\nrounds=3\nlang=en\n' > .sol/REVIEW`
- `on post` → same but `mode=post` (reviewer may post to GitHub; confirm with the user first)
- `off` → `rm -f .sol/REVIEW`
- `status` (or empty) → print `.sol/REVIEW` or "review off"
Reply in one line. Takes effect for the reviewer directive at the next session start.
