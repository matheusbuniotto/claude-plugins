#!/usr/bin/env bash
# fail-open wrapper: a missing jq or a syntax error in hook.sh must never block tools
D="$(dirname "$0")"
command -v jq >/dev/null 2>&1 || { echo "sol: jq not found; sol hooks disabled (install jq)" >&2; exit 0; }
bash -n "$D/hook.sh" 2>/dev/null || { echo "sol: hook.sh has a syntax error; hooks disabled until fixed" >&2; exit 0; }
exec "$D/hook.sh" "$@"
