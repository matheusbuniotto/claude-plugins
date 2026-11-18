import type { Register } from 'claude-code'

// Reads .sol/ in the session's directory and shows one status-line entry:
//   sol: 2 running · 1 stuck · pro 2 · review
// A store is "running" while it has no out.md, "stuck" when nothing in it changed for `stuckMinutes`.
export const register: Register = (on, options) => {
  const stuckMs = (Number(options?.stuckMinutes) || 10) * 60_000

  on('session.start', ($, e, next) => {
    const cwd = e.cwd
    const refresh = async () => {
      try {
        const root = `${cwd}/.sol`
        if (!(await $.fs.exists(root))) return $.ui.status(undefined)
        const entries = await $.fs.list(root)
        let running = 0
        let stuck = 0
        for (const d of entries.filter(x => x.kind === 'dir')) {
          const files = await $.fs.list(`${root}/${d.name}`)
          if (files.some(f => f.name === 'out.md')) continue
          const last = Math.max(d.mtimeMs, ...files.map(f => f.mtimeMs))
          if (Date.now() - last > stuckMs) stuck++
          else running++
        }
        const parts: string[] = []
        if (running) parts.push(`${running} running`)
        if (stuck) parts.push(`${stuck} stuck`)
        for (const f of entries) {
          if (f.name === 'PRO') parts.push(`pro ${(await $.fs.read(`${root}/PRO`)).trim()}`)
          if (f.name === 'REVIEW') parts.push('review')
        }
        $.ui.status(parts.length ? `sol: ${parts.join(' · ')}` : undefined)
      } catch {
        $.ui.status(undefined)
      }
    }
    $.clock.every(5000, () => void refresh())
    return next(e)
  })
}
