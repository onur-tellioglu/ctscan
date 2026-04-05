# Mend — Visual Redesign Spec
**Date:** 2026-04-05
**Status:** Approved
**Replaces:** `mend-design-guide.md` (visual section only — architecture unchanged)

---

## Decision Summary

The original design guide used macOS system colors and native patterns. This spec replaces that visual language with an opinionated, branded identity that makes Mend feel like a distinct product rather than a system utility.

---

## Identity

| | |
|---|---|
| **Character** | Opinionated, trustworthy, precision tool. Not a system utility — a product. |
| **Personality** | Clean confidence. Data at a glance. Feels like it was made with care. |
| **References** | Linear (craft), Raycast (precision), Arc (glass material) |

---

## Color

### Palette

Never use hardcoded system semantic colors for brand decisions. The following values are intentional design tokens.

**Brand / Accent — Teal**

| Token | Light | Dark |
|-------|-------|------|
| `accent.primary` | `#0d9488` (teal-600) | `#2dd4bf` (teal-400) |
| `accent.secondary` | `#2dd4bf` (teal-400) | `#0d9488` (teal-600) |
| `accent.subtle` | `rgba(13,148,136,0.10)` | `rgba(45,212,191,0.10)` |
| `accent.gradient` | `linear(135°, #0d9488 → #2dd4bf)` | same |

**Status colors**

| Status | Light | Dark |
|--------|-------|------|
| ok | `#22c55e` (green-500) | `#22c55e` |
| warn | `#f59e0b` (amber-500) | `#f59e0b` |
| error | `#ef4444` (red-500) | `#ef4444` |
| unavailable | `#94a3b8` (slate-400) | `#334155` (slate-700) |

Status dots get a `box-shadow: 0 0 6px <color>@50%` glow in both modes.

**Surfaces**

| Role | Light | Dark |
|------|-------|------|
| Window background | `linear(160°, #f0fdfa → #ecfdf5 → #f0f9ff)` | `linear(160°, #021a18 → #041a24 → #050d1a)` |
| Sidebar background | `rgba(255,255,255,0.50)` + blur(16px) | `rgba(255,255,255,0.03)` |
| Card / glass surface | `rgba(255,255,255,0.65)` + blur(12px) | `rgba(255,255,255,0.04)` |
| Card border (ok) | `rgba(255,255,255,0.95)` | `rgba(45,212,191,0.10)` |
| Card border (warn) | `rgba(254,243,199,0.90)` | `rgba(245,158,11,0.18)` |
| Sidebar divider | `rgba(204,251,241,0.80)` | `rgba(45,212,191,0.10)` |

**Text**

| Role | Light | Dark |
|------|-------|------|
| Primary | `#0f172a` (slate-900) | `#f1f5f9` (slate-100) |
| Secondary | `#94a3b8` (slate-400) | `#334155` (slate-700) |
| Label / uppercase | `#94a3b8` | `#334155` |
| Active nav item | `accent.primary` | `accent.primary` |
| Inactive nav item | `#64748b` (slate-500) | `#64748b` (slate-500) |

---

## Typography

All type uses `-apple-system, BlinkMacSystemFont` (SF Pro). No external font.

| Role | Size | Weight | Notes |
|------|------|--------|-------|
| App name (sidebar) | 13pt | 700 | letter-spacing: −0.3px |
| Nav item (active) | 11pt | 600 | teal color |
| Nav item (inactive) | 11pt | 400 | secondary color |
| Section title | 16pt | 600 | letter-spacing: −0.3px |
| Section subtitle | 11pt | 400 | secondary color |
| Card label | 9pt | 700 | UPPERCASE, letter-spacing: 1.5px |
| Card value | 28pt | 300 | letter-spacing: −1px |
| Card unit suffix | 13pt | 400 | secondary/muted color |
| Card detail | 10pt | 400 | secondary color |
| Row module name | 12pt | 500 | primary color |
| Row value | 11pt | 400 | secondary, tabular-nums |
| Hero headline | 11pt | 700 | UPPERCASE, letter-spacing: 2px, teal |
| Hero subline | 20pt | 300 | primary, letter-spacing: −0.5px |
| Score number | 18pt | 700 | letter-spacing: −1px |
| Timestamp / meta | 9pt | 400 | secondary |

**Rule:** values are large and light-weight (300). Labels are small, heavy, uppercase. This contrast creates the visual hierarchy — the number answers before you read the label.

---

## Layout

### Window
- Minimum size: **860 × 600**
- Resizable: yes
- Window style: `.hiddenTitleBar`

### Navigation — Full-width Sidebar

Replace the top tab bar from the previous spec with a full-width sidebar.

```
┌──────────────┬──────────────────────────────────┐
│  ● Mend      │                                  │
│──────────────│          Content Area            │
│  Overview ◀  │                                  │
│  Scan        │                                  │
│  Clean       │                                  │
│  Apps        │                                  │
│  Updates  1  │  (badge if warn/error)           │
│  Startup     │                                  │
│  Storage     │                                  │
│──────────────│                                  │
│  2m ago      │                                  │
└──────────────┴──────────────────────────────────┘
```

- Sidebar width: **130pt** fixed
- Active item: teal text + `accent.subtle` background, border-radius 8pt
- Inactive item: secondary text
- Badge (warn count): orange pill, right-aligned in nav row
- Bottom: "Scanned Xm ago" in 9pt secondary
- Sidebar background: glass surface (see Colors)
- Sidebar border-right: `rgba(204,251,241,0.80)` light / `rgba(45,212,191,0.10)` dark

### Sidebar icons

Lucide-style SVG icons (15×15, stroke-width 1.75, stroke-linecap round, stroke-linejoin round). No emoji. No SF Symbols in sidebar — SVG for cross-context consistency.

| Section | Icon |
|---------|------|
| Overview | grid-2×2 |
| Scan | activity (waveform) |
| Clean | trash |
| Apps | monitor |
| Updates | info-circle |
| Startup | radio-circle |
| Storage | database |

Active state: stroke color = `accent.primary`. Inactive: secondary color.

---

## Components

### Overview Tab

#### Hero card
Full-width card at top of Overview. Glass surface. Contains:
- **Health ring** (80×80 SVG circle): teal gradient stroke, score number center
- **Status headline**: UPPERCASE teal label + light weight sentence below
- **Warning summary**: "X warnings · Y errors" in secondary
- **Scan Now button**: teal gradient fill, border-radius 10pt, teal box-shadow

Score calculation: average of module statuses (ok=100, warn=60, error=0, unavailable=ignored).

#### MetricCard (glass card grid)
3-column `LazyVGrid`, 10pt gap.

```
┌─────────────────────────────┐
│ BATTERY              ● green │  ← label + status dot
│                             │
│  97.2%                      │  ← large light value + muted unit
│  312 cycles · excellent     │  ← detail (secondary)
│  ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░          │  ← progress bar (3pt, teal/warn)
└─────────────────────────────┘
```

- Border: ok → `rgba(255,255,255,0.95)` / warn → `rgba(254,243,199,0.90)`
- Background: glass surface
- Corner radius: 14pt
- Padding: 16pt
- Progress bar: 3pt height, border-radius 99pt, teal for ok, amber for warn
- Status dot: 6×6pt, glowing box-shadow

### ScanRow

```
[icon]  Module Name          value      ● [›]
        expanded detail (if tapped)
```

- Icon: SVG, 15×15, secondary color
- Module name: 12pt medium
- Value: 11pt secondary, right-aligned, tabular-nums
- Status dot: 6×6pt glow
- Expand chevron: shown only when row has detail; rotates 90° on expand
- Expanded detail: 10pt, secondary color, key-value pairs, left-padded 43pt
- Warn row: subtle `rgba(245,158,11,0.025)` background tint
- Row separator: `rgba(226,248,245,0.70)` light / `rgba(45,212,191,0.08)` dark

---

## Motion

| Interaction | Animation |
|-------------|-----------|
| Scan row expand/collapse | `.easeInOut(0.15s)` opacity + height |
| Tab / section switch | instant (no animation) |
| Scan in progress | system `ProgressView` spinner, no custom |
| Score ring on load | draw stroke from 0 → value, `.easeOut(0.4s)` |
| Status dot appear | `.easeOut(0.2s)` scale from 0 |

Keep motion minimal and brief. The app handles data — it should feel precise, not playful.

---

## Dark Mode

Full light + dark support. Follows `@Environment(\.colorScheme)`.

- Window background: deep teal-dark gradient (see Surfaces)
- Glass cards: near-transparent with teal border tint
- Teal accent shifts from `#0d9488` → `#2dd4bf` (brighter in dark)
- Glowing status dots are more visible in dark (increase shadow opacity by ~20%)
- Sidebar inactive text: `#334155` (slate-700) — visibly darker than content

---

## What Changed from Previous Design Guide

| Before | After |
|--------|-------|
| System semantic colors | Custom teal token system |
| Top tab bar | Full-width sidebar |
| Native feel (ships-with-macOS) | Opinionated branded identity |
| Small, light metric values | Large (28pt) light-weight values |
| Blue/indigo accent | Teal/cyan accent |
| SF Symbol icons | Lucide-style SVG icons |
| No hero/score concept | Health score ring in Overview |
| Light only | Light + Dark |

---

## File Ownership (updated)

Components are unchanged in structure — only visual implementation changes.

| File | What changes |
|------|-------------|
| `App/AppState.swift` | Add `healthScore: Int` computed from results |
| `ContentView.swift` | Replace tab bar with sidebar `NavigationSplitView` or manual HStack |
| `Features/Overview/OverviewView.swift` | Add hero card above grid |
| `Features/Overview/MetricCard.swift` | New glass styling, progress bar, teal tokens |
| `Features/Scan/ScanRowView.swift` | SVG icons, new row styling |
| `Resources/DesignTokens.swift` | New file — color/spacing tokens (light+dark) |

---

*This spec supersedes the visual section of `mend-design-guide.md`. Architecture, data flow, and feature specs in the main design doc remain unchanged.*
