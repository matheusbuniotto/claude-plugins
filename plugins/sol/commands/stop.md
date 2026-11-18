---
description: Break stuck sol loops (ends pro mode, frees agent slots, keeps stores)
---
Run `"${CLAUDE_PLUGIN_ROOT}/skills/sol/stop.sh"` in the current project dir. Stop any running sol subagents with TaskStop first. Then report ⚠️ with the last checkpoint of any kept `.sol/<id>` store. Do not retry the stuck step.
