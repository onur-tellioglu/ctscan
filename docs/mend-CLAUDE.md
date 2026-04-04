# CLAUDE.md — Mend

> Copy this file to the root of the `mend` repo as `CLAUDE.md` when the Xcode project is created.

## Design guide

**Read `docs/mend-design-guide.md` before touching any UI code.** It is the source of truth for colors, typography, spacing, components, icons, animation, and file ownership. All decisions there are intentional.

The short version:
- System semantic colors only — no hex values
- Status always shown as color + SF Symbol badge
- MetricCard: 14pt padding, 10pt corner, `controlBackgroundColor` fill
- Tab bar is a manual `HStack` switch — not SwiftUI `TabView`
- Window minimum: 860 × 600
- Destructive actions always require a confirmation sheet

## Architecture

Mend is a SwiftUI macOS app that bundles the `ctscan` CLI binary and calls it via `Process` API.

- `Scanner/CtscanRunner.swift` — spawns `ctscan --format json`, decodes output
- `App/AppState.swift` — single `@MainActor ObservableObject` driving the whole app
- `MenuBar/MenuBarController.swift` — `NSStatusItem` + background scan timer
- `Resources/ctscan` — bundled binary (copy from ctscan repo's `bin/ctscan` to update)

## Build & test

```bash
# Build
xcodebuild -project Mend.xcodeproj -scheme Mend -destination 'platform=macOS' build

# Test
xcodebuild -project Mend.xcodeproj -scheme MendTests -destination 'platform=macOS' test
```

Or use ⌘B / ⌘U in Xcode.

## Key rules

- Never parse ctscan text output — always use `--format json`
- `AppState.shared` is the single source of truth for scan state — don't hold results elsewhere
- All deletions (Phase 2+) must show a confirmation sheet before executing
- Run `MendTests` after any change to `Scanner/` or `App/`

## Related files

- Design guide: `docs/mend-design-guide.md`
- Spec: `docs/superpowers/specs/2026-04-05-mend-design.md`
- Phase 1 plan: `docs/superpowers/plans/2026-04-05-mend-phase1.md`
