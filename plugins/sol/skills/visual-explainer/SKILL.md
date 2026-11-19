---
name: visual-explainer
description: Explain visually - build a local HTML page that draws a concept, system, code, architecture, process or data as big pictures in plain ELI10 words. Use for "explain visually", "draw this", "make an html to explain", "visual explanation", "diagram in html", "eli5/eli10 page", "desenha isso", "explica visualmente". Also planner mode: plan a feature/project/change, "design doc", "technical design", "TDD", "RFC", "spec", "planner", "planeja", "documento técnico".
---

# visual-explainer

Two modes: **explain** (default, below) for something that exists; **planner** (see "Planner mode") when the user wants something planned/designed.

Output: one self-contained `.html` file (inline CSS/SVG/JS, no build step, no external deps, works via `file://`). Goal: a 10-year-old gets the idea from the pictures alone. Write all page text (titles, captions, labels, analogies, recap) and your chat reply in the language the user wrote their request in, whatever it is; set `<html lang>` to match. Never default to English.

When writing a page, read `~/.claude/skills/visual-explainer/base.md` first: it holds the base CSS (paste it verbatim), SVG patterns, sizing rules, the diagram-type table, common mistakes and the render-check command.

## Steps

1. **Restate** the topic as one ELI10 sentence. Done when it has no jargon.
2. **Pick the diagram** per section from the "Diagram type per question" table in base.md. One form per section; 3-6 sections.
3. **Write** `explain-<topic>.html` in the cwd (`~/Desktop` if there is no project cwd): base CSS + the page structure below.
4. **Render-check** with the command in base.md at phone width (390px), desktop width and forced dark; read the screenshots. Done when the review checklist is all yes; otherwise fix and re-render.
5. **Open** it: `open <path>`, and report the path in 1-2 lines.

## Page structure

- **The whole idea**: one sentence at the top.
- **Hero diagram**: inline SVG, full content width.
- **Steps**: numbered sections, each a picture plus a 1-2 sentence caption. One idea per section.
- **"In real life it's like..."**: small box with an everyday analogy.
- **Recap**: tiny, at the bottom.

## Style rules

- Plain words, short sentences, everyday analogies; define each jargon term the first time it appears.
- Pictures carry the meaning; text only captions. Emoji/icons welcome.
- Diagram text 24 units in a 600-wide viewBox (sizing rules in base.md), strokes 3px+, high contrast, at most 3 words per node.
- Colors only through the `var(--...)` tokens; light and dark come with the base CSS.
- Interactivity (hover/click step-through, next/prev, CSS animation) only where it clarifies.

## Review checklist

- Would a 10-year-old get it?
- Is the biggest element a picture?
- Any paragraph over 2 sentences?
- On the phone screenshot, is every label readable and un-overlapped, with arrowheads on all arrows?
- Every jargon word defined?

## Skeleton

```html
<!doctype html><html lang="en"><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Explain: TOPIC</title>
<style>/* base CSS from base.md */</style>
<h1>The whole idea in one sentence.</h1>
<svg viewBox="0 0 600 200" role="img" aria-label="hero diagram">
 <defs><!-- #arr marker from base.md --></defs>
 <!-- labeled nodes + .edge paths from base.md -->
</svg>
<h2>1. First step</h2><svg viewBox="0 0 600 180" role="img" aria-label="step 1"></svg><p>Short caption.</p>
<div class="box">In real life it's like...</div>
<p><b>Recap:</b> one line.</p>
</html>
```

## Planner mode / technical design doc

Trigger: plan a feature/project/change, "design doc", "technical design", "TDD", "RFC", "spec", "planner", "planeja", "documento técnico". Output: one `design-<topic>.html`, same rules as above (base.md, user's language, render-check, `open`, report path), plus the print styles from base.md. Visual-first but technically complete. Reuse the skeleton below; only the extra parts are added.

### Steps

1. **Ground** in the real codebase if one exists: read the relevant files, cite paths (`path:line`). Done when every claim about current state has a path.
2. **Gaps**: ask at most 3 questions, or put the gap in Open questions. Never invent facts, numbers or answers.
3. **Write** the sections below in order; keep each scannable (diagram, table or list first, max 2-sentence paragraphs). Diagrams use viewBox width up to 1000 inside `<div class="scroll">`.
4. **Render-check** (phone, desktop, dark, and the print PDF if Chromium is present), then run the self-review. Done when every answer is yes.
5. **Open**, report the path.

### Sections

1. **TL;DR** (3 lines) + **ELI10** one-sentence idea.
2. **Problem & goals / non-goals**.
3. **Context**: current-state diagram (SVG).
4. **Proposed design**: big architecture SVG, components, data flow, data model / APIs / interfaces as code blocks.
5. **Alternatives considered**: comparison table or cards, pros/cons, why rejected.
6. **Plan**: phased milestones as a roadmap/timeline SVG; task checklist with size (S/M/L) and dependencies.
7. **Risks & mitigations** (table, one mitigation per risk); **Open questions**, badged "OPEN", each with an owner or who can answer.
8. **Testing, rollout, rollback, observability**.
9. **Decision log** + status badge (`Draft`).

### Self-review (fix until all yes)

- Could someone implement from this alone?
- Does every risk have a mitigation?
- Do the diagrams match the text (same component names)?
- Is every fact from the code or the user, with unknowns marked OPEN?
- Is each section scannable, with a visual in sections 3, 4 and 6?
- Does the phone screenshot show readable diagram text and tables that do not overflow the page?

### Skeleton (extra parts only)

```html
<header><h1>Design: TOPIC</h1><span class="badge">Draft</span></header>
<div class="box"><b>TL;DR</b><ul><li></li><li></li><li></li></ul><p>ELI10: one sentence.</p></div>
<h2>2. Problem &amp; goals</h2><ul class="goals"></ul><h3>Non-goals</h3><ul></ul>
<h2>4. Proposed design</h2><div class="scroll"><svg viewBox="0 0 1000 320" role="img" aria-label="architecture"></svg></div>
<pre><code>// interfaces / schema</code></pre>
<h2>5. Alternatives</h2>
<table><tr><th>Option</th><th>Pros</th><th>Cons</th><th>Why not</th></tr></table>
<h2>6. Plan</h2><div class="scroll"><svg viewBox="0 0 1000 220" role="img" aria-label="roadmap"></svg></div>
<ul class="tasks"><li><input type="checkbox"> Task <b>[M]</b> needs: #1</li></ul>
<h2>7. Risks</h2><table><tr><th>Risk</th><th>Mitigation</th></tr></table>
<p class="open"><span class="badge open">OPEN</span> question? <i>Owner: who</i></p>
<h2>9. Decision log</h2><table><tr><th>Date</th><th>Decision</th><th>Why</th></tr></table>
```
