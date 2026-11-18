#!/usr/bin/env bash
# sol-stop: break stuck sol loops. usage: stop.sh [--all]   (run in the project dir)
# Ends pro mode, frees stuck agent slots (parallel cap), clears claims. Keeps .sol/<id> stores for resume.
rm -f .sol/PRO
T="${TMPDIR:-/tmp}/sol-state"
if [ "$1" = --all ]; then rm -rf "$T"; else
  for s in "$T"/*/; do [ -d "$s" ] && rm -rf "$s/run" "$s/web" "$s/own" "$s"/claim.* 2>/dev/null; done
fi
n=$(ls -d .sol/*/ 2>/dev/null | wc -l | tr -d ' ')
echo "✅ sol loops stopped: pro off, agent slots freed; $n store(s) kept in .sol/ (resume or rm)"
