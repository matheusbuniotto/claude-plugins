# Changelog

## 0.2.0
- Slash commands: `/sol:stop`, `/sol:review`, `/sol:pro`.
- Opt-in PR reviewer (`sol-reviewer`), drafts only unless `mode=post`.
- Stuck-loop kill switch (`stop.sh`), stale agent slots expire after 30 min.
- Fail-open `run.sh` (missing `jq` or a syntax error disables hooks instead of blocking tools).
- Per-project output style override: `.sol/STYLE`.
- Tests (`tests/test.sh`) and CI.

## 0.1.0
- Delegation agents, `.sol/` store, hook-enforced limits, terse output, pro mode.
