# visual-explainer base kit

Copy the CSS block verbatim into every page's `<style>`, then add page-specific rules after it. Reference, not steps: SKILL.md says when each part applies.

## Base CSS

```css
:root{--bg:#fff;--fg:#111;--mut:#555;--card:#f5f7fb;--line:#2b2b2b;--a:#0a6cff;--b:#d95f00;--ok:#0a8a3a;--bad:#d62839;--bd:#c9d1dc}
@media (prefers-color-scheme:dark){:root{--bg:#111418;--fg:#f4f4f4;--mut:#aab2bd;--card:#1b2027;--line:#d8dde4;--a:#6aa9ff;--b:#ffa04d;--ok:#4cd07d;--bad:#ff6b7a;--bd:#38414d}}
*{box-sizing:border-box}
body{margin:0 auto;max-width:1100px;padding:16px;background:var(--bg);color:var(--fg);font:18px/1.5 system-ui,sans-serif}
h1{font-size:clamp(26px,5vw,40px);line-height:1.2;margin:.4em 0}
h2{font-size:clamp(22px,4vw,30px);margin:1.6em 0 .4em}
p,li{max-width:70ch}
svg{display:block;width:100%;height:auto;margin:8px 0}
svg text{font-size:24px;fill:var(--fg);font-family:inherit}
svg .sm{font-size:22px;fill:var(--mut)}
.node{fill:var(--card);stroke:var(--a);stroke-width:3}
.edge{stroke:var(--line);stroke-width:3;fill:none;marker-end:url(#arr)}
.scroll{overflow-x:auto}.scroll svg{min-width:640px}
.box{border:3px solid var(--b);border-radius:12px;padding:12px 16px;background:var(--card);margin:16px 0}
.badge{display:inline-block;padding:2px 10px;border-radius:999px;font:600 14px/1.6 system-ui;background:var(--a);color:var(--bg);vertical-align:middle}
.badge.open{background:var(--b)}.badge.ok{background:var(--ok)}.badge.bad{background:var(--bad)}
table{border-collapse:collapse;width:100%;margin:12px 0;font-size:16px}
th,td{border:2px solid var(--bd);padding:8px 10px;text-align:left;vertical-align:top}
th{background:var(--card)}
code,pre{font:15px/1.5 ui-monospace,Menlo,monospace}
pre{background:var(--card);border:2px solid var(--bd);border-radius:8px;padding:12px;overflow-x:auto}
@media (prefers-reduced-motion:reduce){*{animation:none!important;transition:none!important}}
```

Motion: put animation rules inside `@media (prefers-reduced-motion:no-preference){...}`; the reduce rule above is the safety net.

Print styles (design docs; append to the base CSS):

```css
@media print{
 :root{--bg:#fff;--fg:#000;--mut:#444;--card:#fff;--line:#000;--bd:#888}
 body{max-width:none;padding:0;font-size:12pt}
 h2{break-after:avoid}svg,table,pre,.box,tr{break-inside:avoid}
 .scroll{overflow:visible}.scroll svg{min-width:0}
 a[href^=http]::after{content:" (" attr(href) ")";font-size:9pt}
 .noprint,button{display:none}
}
```

## SVG patterns

Define the arrow once, in the first `<svg>`; inline SVGs on one page share ids. Edges use `class="edge"`.

```html
<defs><marker id="arr" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse"><path d="M0 0L10 5L0 10z" fill="var(--line)"/></marker></defs>
```

Labeled node: rect sized to its text (about 14 units per character at 24px), text centered at the rect's middle.

```html
<g><rect class="node" x="40" y="60" width="200" height="80" rx="14"/><text x="140" y="108" text-anchor="middle">Gateway</text></g>
<path class="edge" d="M240 100H400"/>
<text class="sm" x="320" y="88" text-anchor="middle">asks</text>  <!-- edge label sits above the line, clear of both nodes -->
```

Step number badge (put at a node's top-left corner):

```html
<g><circle cx="40" cy="60" r="20" fill="var(--b)"/><text x="40" y="69" text-anchor="middle" style="fill:var(--bg);font-weight:700">1</text></g>
```

## Sizing rules for SVG (text scales with the picture)

- Phone shows an SVG at about 360px wide, so effective text px = font-size x 360 / viewBox width. Keep it at 13px or more.
- Explain pages: viewBox width 600, text 24 units (14px on phone), at most 2-3 nodes per row; stack vertically for more. Design docs: viewBox width up to 1000 inside `<div class="scroll">`, text 22+ units (14px at the 640px scroll minimum).
- Edge labels (`.sm`, about 11 units per character) must be shorter than the gap between nodes minus 40 units; otherwise widen the gap or move the label above or below.
- viewBox height hugs the content: 20 units of padding, no empty bands.
- Stack nodes vertically instead of widening past 1000.
- Every `<svg>` has `viewBox`, `role="img"` and an `aria-label`; no fixed `width`/`height` attributes.

## Diagram type per question

| Question | Draw |
|---|---|
| What happens, in what order? | flow (left to right, numbered nodes) |
| Who talks to whom? | sequence: lifelines top to bottom, arrows between |
| What is it made of? | layers or nested boxes |
| What changed? | before / after, two panels, same positions |
| Which one should I pick? | comparison table or cards with a verdict row |
| When, and how long? | timeline or roadmap lanes |
| What repeats? | cycle (4-6 nodes in a ring) |
| How are things related? | map or graph, at most 8 nodes |
| How much? | bar chart, bars in one color, value labels at bar ends |

## Common mistakes

- Tiny text: SVG text under 20 units, or a viewBox wider than 600 on an explain page (1000 on a design doc, inside `.scroll`).
- Overlapping labels: put edge labels beside lines with 12+ units of clearance; widen the node rather than shrinking its text; at most 3 words per node.
- Text walls: more than 2 sentences in a paragraph, or a section without a picture.
- Missing `viewBox` or `role="img"` / `aria-label` on an SVG.
- Arrows without heads: use `class="edge"` and the `#arr` marker.
- Hard-coded colors in SVG: use the `var(--...)` tokens so dark mode works.
- Unlabeled axes, boxes or edges.
- Same component named differently in the diagram and in the text.

## Render check

```sh
H=$(ls ~/Library/Caches/ms-playwright/chromium_headless_shell-*/chrome-headless-shell-mac-arm64/chrome-headless-shell 2>/dev/null | tail -1)
C="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"; [ -x "$C" ] && H="$C"
"$H" --headless --no-sandbox --hide-scrollbars --window-size=390,1800 --screenshot=/tmp/m.png file://$PWD/page.html
"$H" --headless --no-sandbox --hide-scrollbars --window-size=1200,1800 --screenshot=/tmp/d.png file://$PWD/page.html
```

Read both PNGs (phone width, desktop width). For dark, render a copy with the dark media query forced on (`--force-dark-mode` does not change `prefers-color-scheme`): `sed 's/@media (prefers-color-scheme:dark)/@media all/' page.html > dark.html`. For print, add `--no-pdf-header-footer --print-to-pdf=/tmp/p.pdf` and read the PDF. Without any Chromium: check that every `<svg` has `viewBox`, that no `font-size` is below 20 in an SVG, and that every `<marker` id is referenced.
