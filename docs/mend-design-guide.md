# Mend — Tasarım Kitapçığı (Design Guide)

> **For Claude / agents:** Read this before touching any Mend UI code. Every visual decision here is intentional — don't deviate without a reason.

---

## Identity

| | |
|---|---|
| **App name** | Mend |
| **Tagline** | Care for your Mac |
| **Personality** | Clean, trustworthy, restorative. Not a dashboard — a caretaker. |
| **Install** | `brew install --cask mend` |
| **Min macOS** | 13.0 (Ventura) |

---

## Color

Use **system semantic colors everywhere**. Never hardcode hex values. The app must look correct in both light and dark mode automatically.

### Status colors

| Status | SwiftUI color | Usage |
|--------|--------------|-------|
| `.ok` | `.green` | All checks passed |
| `.warn` | `.orange` | Actionable warning |
| `.error` | `.red` | Critical issue |
| `.unavailable` | `Color(.systemGray)` | Tool missing or not configured |

These are defined on `ModuleStatus.color` in `ScanResult.swift`. Always use that property — never inline the color.

### Background colors

| Role | Color |
|------|-------|
| Window background | `Color(.windowBackgroundColor)` |
| Card / row fill | `Color(.controlBackgroundColor)` |
| Tab bar background | `Color(.windowBackgroundColor)` |
| Selected tab highlight | `Color(.selectedControlColor)` |

### Text colors

| Role | Color |
|------|-------|
| Primary text | `.primary` |
| Secondary / labels | `.secondary` |
| Destructive | `.red` |

---

## Typography

| Role | Font | Where |
|------|------|-------|
| Metric value | `.system(size: 22, weight: .light, design: .rounded)` | MetricCard large value |
| Card label | `.system(size: 11, weight: .semibold)` | Uppercase module label |
| Row label | `.system(size: 13)` | ScanRow module name |
| Detail / message | `.system(size: 12)` | Card message, row detail |
| Monospaced value | `.system(size: 12, design: .monospaced)` | Scan tab value column |
| Timestamp / meta | `.system(size: 11)` | "Last scanned X ago" |
| Delta indicator | `.system(size: 10)` | History delta in MetricCard |

**Rule:** metric *values* are large and light-weight. Labels and supporting text are small. This contrast is what gives the Overview tab its visual hierarchy.

---

## Spacing

| Token | Value | Usage |
|-------|-------|-------|
| Card padding | `14pt` | Inner padding of MetricCard |
| Grid gap | `12pt` | Gap between MetricCards in LazyVGrid |
| Page margin | `16pt` | ScrollView content padding |
| Row h-padding | `16pt` | ScanRow horizontal inset |
| Row v-padding | `10pt` | ScanRow vertical inset |
| Corner radius — card | `10pt` | MetricCard RoundedRectangle |
| Corner radius — chip | `6pt` | Tab highlight, small badges |

---

## Components

### MetricCard

**File:** `Mend/Features/Overview/MetricCard.swift`

A tappable card showing one module's health at a glance.

```
┌─────────────────────────────┐
│ 🔋 Battery          ✓ green │  ← icon + label + status badge
│                             │
│  97.2%                      │  ← large light value
│  312 cycles                 │  ← message (small, secondary)
│  97.8% → 97.2% since last   │  ← delta (only if changed)
└─────────────────────────────┘
```

- Border color: `Color(.separatorColor).opacity(0.5)` when ok; `status.color.opacity(0.4)` when warn/error
- Fill: always `Color(.controlBackgroundColor)`
- Corner radius: 10pt
- Tap → navigate to the relevant detail tab (implement in Phase 2+)

### ScanRowView

**File:** `Mend/Features/Scan/ScanRowView.swift`

One row per module in the Scan tab.

```
 🔋  Battery              97.2%   ✓    ›
     312 cycles (expanded detail)
```

- Icon width: 18pt fixed (keeps all labels aligned)
- Value: monospaced, `.secondary`
- Status badge: SF Symbol from `ModuleStatus.badgeSymbol`
- Expand chevron: only visible if `message` is non-empty
- Expand animation: `.easeInOut(duration: 0.15)`

### Tab bar

**File:** `Mend/ContentView.swift`

Horizontal bar at the top of the window. Plain button style. Selected tab gets a `Color(.selectedControlColor)` rounded rect background (corner 6pt). Not a `TabView` — it's a manual `HStack` with a `switch` on `selectedTab`.

**Reason for not using `TabView`:** macOS `TabView` puts tabs at the top or bottom with system chrome that doesn't match the intended design. Manual tab bar gives full control.

---

## Icons (SF Symbols)

All icons are SF Symbols. No custom assets unless absolutely necessary.

### Module icons

| Module | Symbol |
|--------|--------|
| identity | `desktopcomputer` |
| battery | `battery.100` |
| thermal | `thermometer.medium` |
| memory | `memorychip` |
| storage | `internaldrive` |
| ssd | `externaldrive` |
| processes | `cpu` |
| brew | `shippingbox` |
| docker | `shippingbox.and.arrow.backward` |
| timemachine | `clock.arrow.circlepath` |
| updates | `arrow.down.circle` |
| wifi | `wifi` |
| security | `lock.shield` |
| agents | `gearshape.2` |

### Status badge symbols

Defined on `ModuleStatus.badgeSymbol`:

| Status | Symbol |
|--------|--------|
| ok | `checkmark.circle.fill` |
| warn | `exclamationmark.triangle.fill` |
| error | `xmark.circle.fill` |
| unavailable | `minus.circle.fill` |

### Menu bar

| State | Symbol |
|-------|--------|
| All ok | `stethoscope` |
| Any warn | `stethoscope.circle.fill` |
| Any error | `exclamationmark.circle.fill` |

---

## Layout

### Window

- Minimum size: **860 × 600**
- Resizable: yes
- Window style: `.hiddenTitleBar`
- The window should never be smaller than 860pt wide — MetricCard grid needs 3 columns to breathe

### Overview tab grid

- `LazyVGrid` with 3 flexible columns, 12pt spacing
- Modules shown in Overview: `battery`, `storage`, `thermal`, `memory`, `brew`, `timemachine`, `updates`, `security`, `wifi` (9 cards)
- Scroll enabled — do not clip content

### Scan tab list

- Plain `List` (`.listStyle(.plain)`)
- All 14 modules, in `allModules` order (defined in `ScanRowView.swift`)
- Row separators: `.visible`

---

## Motion

Keep animations subtle and brief. The app handles system data — it should feel precise, not playful.

| Interaction | Animation |
|-------------|-----------|
| Row expand/collapse | `.easeInOut(duration: 0.15)` with `.opacity` + `.move(edge: .top)` |
| Tab switch | No animation (instant) |
| Scan progress | `ProgressView()` — system spinner, no custom loading states |

---

## Design principles

1. **Data first.** Values are large. Labels are small. The number answers the question before you read the label.

2. **Status at a glance.** Every module always shows a color + icon. Never show data without a status indicator.

3. **Native feel.** System colors, system fonts, system symbols. Mend should look like it shipped with macOS.

4. **No clutter.** Show the most important metric per module in the Overview. Details live in the Scan tab. Don't repeat information across tabs.

5. **Destructive actions require confirmation.** Any deletion (Phase 2+) must show a sheet with file count + total size before proceeding. Never delete silently.

---

## File ownership map

| File | Owns |
|------|------|
| `Scanner/ScanResult.swift` | `ModuleResult`, `ModuleStatus`, `ScanResults`, `ScanSnapshot`, `overallStatus` |
| `Scanner/CtscanRunner.swift` | Process spawning, JSON decoding, `CtscanError` |
| `Scanner/HistoryStore.swift` | `~/.mend/history.json` read/write/prune |
| `App/AppState.swift` | `@Published results`, `isScanning`, `lastScanned`, `scanError`, `delta(for:)` |
| `MenuBar/MenuBarController.swift` | `NSStatusItem`, scan timer, badge icon, click handler |
| `ContentView.swift` | Tab bar, tab switching, `MendTab` enum, `allModules` constant |
| `Features/Overview/MetricCard.swift` | MetricCard component |
| `Features/Overview/OverviewView.swift` | Overview tab layout and card grid |
| `Features/Scan/ScanRowView.swift` | ScanRowView component, `allModules` constant |
| `Features/Scan/ScanView.swift` | Scan tab layout |

**Rule:** if you need to change what a component looks like, touch only its own file. If you need to change data flow, touch `AppState.swift`. If you need to change ctscan invocation, touch `CtscanRunner.swift`.

---

## ctscan integration notes

- Mend bundles the ctscan binary at `Mend.app/Contents/Resources/ctscan`
- Access it via `Bundle.main.url(forResource: "ctscan", withExtension: nil)`
- Always call with `--format json` — never parse text output
- The binary is executable (`chmod +x` applied in a build phase Run Script)
- To update the bundled binary: copy the new `bin/ctscan` from the ctscan repo into `Mend/Resources/ctscan` and commit

---

*This document is the source of truth for Mend's visual design. Update it when intentional design decisions change.*
