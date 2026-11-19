# Changelog

## 0.3.0
- `planner` agent: simple plan, TDD or analytical design doc (read-only on the project).
- `visual-explainer` skill: ELI10 visual HTML explainers, plus planner mode for visual design docs.

## 0.2.0
- Slash commands: `/sol:stop`, `/sol:review`, `/sol:pro`.
- Opt-in PR reviewer (`sol-reviewer`), drafts only unless `mode=post`.
- Stuck-loop kill switch (`stop.sh`), stale agent slots expire after 30 min.
- Fail-open `run.sh` (missing `jq` or a syntax error disables hooks instead of blocking tools).
- Per-project output style override: `.sol/STYLE`.
- Tests (`tests/test.sh`) and CI.

## 0.1.0
- Delegation agents, `.sol/` store, hook-enforced limits, terse output, pro mode.
