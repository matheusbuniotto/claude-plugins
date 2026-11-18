# sol-status

Status-line mod for [sol](../sol). Shows `sol: 2 running · 1 stuck · pro 2 · review`, read from `.sol/` every 5 s; clears when nothing is active.

- running = a `.sol/<id>/` store without `out.md`
- stuck = no file in it changed for `stuckMinutes` (default 10); run `/sol:stop`

```
/plugin install sol-status --marketplace matheusbuniotto/claude-plugins
```
Needs a terminal or desktop session. Reads files only; changes nothing.
