# ctscan Website Rebrand — Design Spec
_Date: 2026-04-04_

## Overview

Rebrand the ctscan landing page from its current phosphor-green retro-terminal aesthetic to an **Authentic macOS Dark** look — the site should feel like a genuine Mac screenshot, not a themed developer page. The Terminal window becomes the primary design artifact.

---

## Aesthetic Direction

**Theme:** Authentic macOS Dark  
**Palette:** macOS system charcoals (`#111113`, `#1e1e1e`, `#3a3a3c`) with macOS system green (`#28c840`) as the only accent. Amber (`#febc2e`) for warnings.  
**Typography:** `SF Mono` / `Menlo` / `Monaco` (system monospace stack) for all terminal content. `-apple-system` / `BlinkMacSystemFont` sans-serif for UI chrome (nav, section headings, body text).  
**No custom font imports** — use native system stacks to reinforce the macOS-native feel.

### What changes vs. current
- Remove: Space Mono, JetBrains Mono, Phosphor icons, scanline overlay, noise texture, neon glow effects, phosphor green (#33ff4d)
- Replace with: system font stacks, genuine Terminal.app chrome, macOS system green (#28c840), no decorative effects
- The logo `ct$` stays — rendered in the new system font stack

---

## Page Structure

### 1. Navigation (sticky, 44px)
- Background: `rgba(17,17,19,0.92)` with `backdrop-filter: blur(8px)`
- Border bottom: 1px `#222`
- Logo: `ct$` in SF Mono, `$` in system green
- Links: Features · Modules · Install · GitHub ↗
- Font: 11px, `#888`, hover `#ddd`

### 2. Hero Section (full viewport height)
- **Eyebrow**: `macOS · Terminal-native · v0.3.8` — SF Mono 10px, system green, uppercase
- **Title**: "Your Mac's health, in one command." — system sans-serif, ~3rem, `#f2f2f7`, tight letter-spacing
- **Subtitle**: "14 diagnostic checks. Zero dependencies. Zero elevated privileges. Results in under a second." — 14px, `#666`
- **Terminal window** (centered, max-width 580px): macOS window chrome (traffic lights + title bar `#3a3a3c`) with a cropped output showing: Identity, Battery, Homebrew (with the ⚠ warning), Security. Blinking cursor at the end.
- **CTAs below window**: `$ brew install ctscan` (primary, green bg, black text) + `View on GitHub ↗` (ghost, border `#333`)
- **Stats strip**: 14 modules · <1s · 0 dependencies — SF Mono, centered, separated by 1px `#222` borders

### 3. About / Features Section
- Background: `#111113`
- Section tag: `about` in SF Mono uppercase, green, with line extending right
- Headline: "No daemon. No GUI. No BS."
- Body: one paragraph, `#666`
- Feature rows (not cards): icon glyph + name + description, separated by `#1e1e1e` border-top

### 4. Full Output Preview Section
- Background: `#111113`
- macOS terminal window (same chrome) containing the **complete real ctscan output** exactly as produced by the tool, scrollable, max-height 420px
- Title bar reads: `ctscan — full output`

**Exact output to render** (verbatim from user's real run):
- All 14 sections: Identity, Homebrew, Launch Agents & Daemons, Storage, SSD Wear, Battery, Thermal & GPU, Memory, Processes, Docker, Time Machine, Updates, Wi-Fi, Security
- Version line: `ctscan 0.3.8`
- Prompt before and after

### 5. Modules Table
- All 14 modules: identity, brew, agents, storage, ssd, battery, thermal, memory, processes, docker, timemachine, updates, wifi, security
- Columns: Module (green) · Checks · Triggers
- Font: SF Mono 11px, dark row separators, hover bg `#1a1a1a`

### 6. Install Section
- Background: `#111113`
- Two install blocks (Homebrew + Git): each has a dark header label, the command in `#e8e8e8` / `#888`, and a `⌘ Copy` button
- Copy-to-clipboard with `✓ Copied` feedback (same as current)
- Requirements note: SF Mono 10px, `#444`

### 7. Footer
- MIT License · onur-tellioglu/ctscan (SF Mono 10px, `#333`)
- GitHub + Issues links

---

## Terminal Color Semantics

| Token | Color | Usage |
|-------|-------|-------|
| `t-prompt` | `#28c840` | Shell prompt (`username@host`) |
| `t-head` | `#28c840` | Section headers (`══ Identity ══`) |
| `t-ok` | `#28c840` | Success indicators (`✓`) |
| `t-warn` | `#febc2e` | Warnings (`⚠`) |
| `t-val` | `#d4d4d4` | Values / readable data |
| `t-key` | `#636366` | Keys, bullet dots (`·`) |
| `t-dim` | `#636366` | Dimmed / secondary info |
| `t-cmd` | `#e8e8e8` | The `ctscan` command itself |

---

## Interactions

- **Scroll reveal**: `IntersectionObserver` fade-up on sections (same as current, keep it)
- **Copy to clipboard**: existing behavior, update visual feedback color to system green
- **Cursor blink**: `█` block cursor at end of hero terminal, CSS `step-end` animation
- **Nav hover**: `#888` → `#ddd`
- **Module row hover**: `#1a1a1a` background
- **Install block hover**: slight border brightening

---

## What Stays

- Single `docs/index.html` file (no build step)
- Tailwind CDN for utility classes
- Smooth scroll + `scroll-padding-top`
- All existing section IDs (`#home`, `#features`, `#modules`, `#install`)
- Copy-to-clipboard JS function
- IntersectionObserver reveal animations

## What Goes

- Space Mono + JetBrains Mono Google Font imports → system font stacks
- Phosphor Icons CDN → no icon library (use text/unicode glyphs)
- `#33ff4d` phosphor green → `#28c840` macOS system green
- Scanline overlay, noise texture, glow effects
- `body::before` noise
- `.glow-phosphor`, `.glow-amber` utilities
- Section labels with gradient pseudo-elements → simpler SF Mono tags

---

## Implementation Notes

- The file is a single `docs/index.html` — rewrite in place
- Tailwind config colors update: replace `phosphor` with `sysgreen: '#28c840'`
- Font families: `font-term: ['SF Mono', 'Menlo', 'Monaco', 'Courier New', monospace]`, `font-ui: ['-apple-system', 'BlinkMacSystemFont', 'sans-serif']`
- Terminal window border-radius: `10px` (matches macOS)
- Traffic lights: red `#ff5f57`, yellow `#febc2e`, green `#28c840` — exact macOS values
- Title bar bg: `#3a3a3c`, border-bottom: `#2a2a2c`
- Terminal body bg: `#1e1e1e`
