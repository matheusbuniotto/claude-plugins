---
description: Sol pro mode: proactively chain follow-ups for N rounds (/sol:pro [rounds] | off)
argument-hint: [rounds] | off
---
Argument: `$ARGUMENTS`.
- number or empty → `mkdir -p .sol && echo <n, default 3> > .sol/PRO`
- `off` → `rm -f .sol/PRO`
Reply in one line with the rounds left.
