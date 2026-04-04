# Mend — Design Spec
**Date:** 2026-04-05
**Status:** Approved

---

## Overview

Mend is a native macOS maintenance app built on top of ctscan. It surfaces the existing ctscan health scanner as a polished SwiftUI experience, and adds app removal, cache cleaning, update management, startup management, and storage analysis — all in one place.

**Name:** Mend
**Install:** `brew install --cask mend`
**Engine:** ctscan CLI (bundled binary, called via Process API)
**New features:** Native Swift (App Remover, Cache Cleaner, Updates, Startup Manager, Storage Analyzer, Menu Bar)

---

## Architecture

### Two repos, one product

| Repo | Role | Change required |
|------|------|----------------|
| `ctscan` | Diagnostic engine — bash CLI | Add `--format json` output mode |
| `mend` | SwiftUI app — new repo | Bundles ctscan binary, wraps it, adds all other features |

ctscan remains a fully independent standalone tool. Mend ships with ctscan embedded at `Mend.app/Contents/Resources/ctscan`. When ctscan cuts a new release, Mend cuts a new release that bundles the updated binary.

### ctscan JSON output (prerequisite)

Add `--format json` flag to `bin/ctscan`. Output is a single JSON object — one key per module:

```json
{
  "battery":    { "status": "ok",   "value": "97.2%",  "message": "312 cycles" },
  "thermal":    { "status": "ok",   "value": "Normal",  "message": "" },
  "memory":     { "status": "ok",   "value": "1.1GB swap", "message": "" },
  "storage":    { "status": "warn", "value": "68%",    "message": "7.3 GB cache" },
  "brew":       { "status": "warn", "value": "4",      "message": "4 packages outdated" },
  "ssd":        { "status": "ok",   "value": "12%",    "message": "" },
  "wifi":       { "status": "ok",   "value": "-54 dBm", "message": "" },
  "security":   { "status": "ok",   "value": "",       "message": "FileVault on, SIP enabled" },
  "timemachine":{ "status": "ok",   "value": "2h ago", "message": "" },
  "updates":    { "status": "warn", "value": "1",      "message": "1 macOS update available" },
  "identity":   { "status": "ok",   "value": "",       "message": "macOS 26.0, 4d uptime" },
  "processes":  { "status": "ok",   "value": "",       "message": "" },
  "docker":     { "status": "ok",   "value": "0",      "message": "No containers running" },
  "agents":     { "status": "ok",   "value": "",       "message": "" }
}
```

`status` is one of: `"ok"`, `"warn"`, `"error"`, `"unavailable"`.

### Data flow — Scan tab

1. Mend app launches → spawns `ctscan --format json` via `Process` API (`--quiet` is irrelevant in JSON mode — the JSON flag always outputs structured data and suppresses all human-readable text)
2. Captures stdout, decodes JSON into `[String: ScanResult]`
3. Stores snapshot to `~/.mend/history.json` (append, keyed by ISO timestamp)
4. SwiftUI renders cards from decoded model, computes deltas vs previous snapshot

### History storage

`~/.mend/history.json` — array of snapshots, max 90 entries (older entries pruned on write):

```json
[
  { "timestamp": "2026-04-05T09:00:00Z", "results": { ... } },
  { "timestamp": "2026-04-04T09:00:00Z", "results": { ... } }
]
```

---

## App Structure

### Navigation

Tab bar across the top of the window. Default tab: Overview.

```
[Overview]  [Scan]  [Clean]  [Apps]  [Updates]  [Startup]  [Storage]
```

Window size: 860×600 minimum, resizable.

### Menu Bar

`NSStatusItem` icon (SF Symbol: `stethoscope` or custom). Runs `ctscan --format json` at launch and every 30 minutes via a background `Timer`. Shows a warning badge (amber dot) if any module returns `warn` or `error`. Click → bring main window to front. Right-click → Quit / Preferences.

---

## Feature Specs by Phase

### Phase 1 — Core experience (v1.0)

**ctscan prerequisite:** Add `--format json` to ctscan first.

#### Overview tab
- Grid of metric cards: Battery %, Disk %, Cache size, Brew outdated count, Thermal state, Last backup age
- Each card shows current value + delta vs last scan (e.g. `↓0.8% since last week` for battery)
- Cards with `warn`/`error` status highlighted in amber/red
- Tapping a card navigates to the relevant tab
- "Scan Now" button top-right — reruns ctscan, refreshes all cards
- Last scanned timestamp shown

#### Scan tab
- Full module list, one row per module: icon, module name, status badge, value, message
- Color-coded: green (ok), amber (warn), red (error), grey (unavailable)
- "Rescan" button
- Expandable rows for modules with detail (battery shows health % + cycles + charge)

#### Menu Bar
- Always-on background scanning
- Badge logic: no badge = all ok; amber dot = any warn; red dot = any error
- Clicking opens Overview tab

### Phase 2 — Action features

#### Apps tab (App Remover)
- List of all `.app` bundles found in `/Applications` and `~/Applications`
- Select an app → scan for associated files using known path patterns:
  - `~/Library/Caches/<bundle-id>`
  - `~/Library/Preferences/<bundle-id>.plist`
  - `~/Library/Application Support/<app-name>`
  - `~/Library/Containers/<bundle-id>`
  - `~/Library/Group Containers/*.<bundle-id>`
- Show found files as a checklist with sizes
- "Move to Trash" button — moves selected files only (never silently deletes)
- Total size recoverable shown before confirmation

#### Clean tab (Cache Cleaner)
- Categorised list: User Caches, Xcode Derived Data, Browser Caches (Chrome, Safari, Firefox), System Logs, iOS Device Backups
- Each category shows total size
- Multi-select categories, preview individual files, delete selected
- Before/after disk savings banner after deletion
- Never deletes without explicit user confirmation (sheet with file count + total size)

### Phase 3 — Power features

#### Updates tab
- Two sections: macOS system updates (`softwareupdate -l`) and Homebrew outdated packages (`brew outdated`)
- Each item shows name, current version, new version
- "Update All" button per section — runs update command in background, shows progress
- Last checked timestamp

#### Startup tab
- Login Items (via `SMAppService`) with enable/disable toggles
- Launch Agents from `~/Library/LaunchAgents` — list with plist filename, associated app name if resolvable, enable/disable
- "Reveal in Finder" action per item
- Read-only for system agents in `/Library/LaunchAgents`, `/Library/LaunchDaemons`

#### Storage tab
- Async folder size enumeration via `FileManager`
- Ranked list of top disk consumers (not a treemap — a bar chart with drill-down)
- Drill into any folder to see sub-breakdown
- "Reveal in Finder" action
- Excludes system paths that can't be cleaned

---

## Error Handling

- If `ctscan` binary not found in bundle: show error card in Scan tab with recovery instructions
- If `ctscan` exits non-zero: show last known results with "stale" badge + error message
- Cache/app deletion errors: show per-file error inline, don't abort the whole operation
- Homebrew not installed: show graceful empty state in Updates tab
- `softwareupdate` requires auth for install (not list): show "open System Settings" CTA rather than attempting inline

---

## Testing

- Unit tests for JSON decoding (`ScanResultDecoder`)
- Unit tests for history storage (write, read, pruning at 90 entries)
- Unit tests for leftover-file path patterns (App Remover)
- UI tests for: scan flow, cache deletion confirmation sheet, app removal flow
- Manual test matrix: macOS Sequoia, macOS Tahoe; Apple Silicon + Intel

---

## Distribution

| Product | Method | Command |
|---------|--------|---------|
| ctscan | Homebrew formula (existing tap) | `brew install ctscan` |
| Mend | Homebrew cask (new tap: `onurtellioglu/mend`) | `brew install --cask mend` |

Mend.app is a signed, notarized macOS app. No App Store (avoids sandboxing restrictions for file system access). Requires an Apple Developer account ($99/year) for signing and notarization.

**Minimum macOS version:** 13.0 (Ventura). Required for `SMAppService` (Startup tab) and stable SwiftUI NavigationSplitView. Apple Silicon + Intel universal binary.

---

## Repo structure (Mend)

```
mend/
  Mend.xcodeproj
  Mend/
    App/
      MendApp.swift          # @main, menu bar setup
      AppState.swift         # ObservableObject, global scan state
    Scanner/
      CtscanRunner.swift     # Process API wrapper, JSON decoder
      ScanResult.swift       # Codable model
      HistoryStore.swift     # ~/.mend/history.json read/write
    Features/
      Overview/
      Scan/
      Clean/
      Apps/
      Updates/
      Startup/
      Storage/
    MenuBar/
      MenuBarController.swift
      MenuBarView.swift
    Resources/
      ctscan                 # bundled binary (copied from ctscan repo on release)
  MendTests/
  MendUITests/
```

---

## Open questions (resolved)

| Question | Decision |
|----------|----------|
| Interface | Native SwiftUI app |
| Distribution | Homebrew cask |
| ctscan relationship | Bundled engine — Mend ships the binary |
| Navigation | Tab bar, Overview first |
| Name | Mend |
| ctscan repo | Unchanged except `--format json` addition |
