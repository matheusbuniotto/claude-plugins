# matheus-plugins

Personal Claude Code plugin marketplace.

| plugin | what |
|---|---|
| [sol](plugins/sol) | Delegate non-trivial work to subagents; durable `.sol/` store; terse output; opt-in PR reviewer; stuck-loop kill switch |

## Use
```
/plugin marketplace add <github-user>/claude-plugins   # or a local path
/plugin install sol@matheus-plugins
```

## Add a plugin
Create `plugins/<name>/` with `.claude-plugin/plugin.json`, then list it in `.claude-plugin/marketplace.json`.
