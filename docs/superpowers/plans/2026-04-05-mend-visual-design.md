# Mend Visual Design System — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the Mend macOS app UI shell using the approved visual design system: teal glass aesthetic, full-width sidebar, hero overview, and SVG-icon scan list — light + dark mode.

**Architecture:** A `DesignTokens.swift` file defines all color/spacing constants for both modes. Reusable atomic views (`StatusDotView`, `HealthRingView`, `ScanIconView`) are composed into `HeroCardView`, `MetricCard`, and `ScanRowView`. `ContentView` hosts a manual sidebar + `@State selectedTab` rather than `TabView`. Every color reference goes through `DesignTokens` — never hardcoded hex.

**Prerequisites:** Phase 1 data layer must exist first — `ScanResult.swift`, `AppState.swift` (with `results: ScanResults` and `isScanning: Bool`), `CtscanRunner.swift`. See `docs/superpowers/plans/2026-04-05-mend-phase1.md` Tasks 1–5.

**Tech Stack:** SwiftUI, AppKit, macOS 13.0+, Xcode 15+, XCTest.

---

## File Map

```
Mend/
  Resources/
    DesignTokens.swift         # NEW — all color/spacing tokens, light+dark
  Shared/
    StatusDotView.swift        # NEW — 6pt glowing dot, parameterised by ModuleStatus
    ScanIconView.swift         # NEW — Lucide SVG paths as SwiftUI Shape, one per section
    HealthRingView.swift       # NEW — animated SVG circle ring showing health score
  Features/
    Overview/
      HeroCardView.swift       # NEW — health ring + status text + Scan Now button
      MetricCard.swift         # REPLACE Phase 1 version — glass card, progress bar
      OverviewView.swift       # REPLACE Phase 1 version — hero above grid
    Scan/
      ScanRowView.swift        # REPLACE Phase 1 version — SVG icon, expand/collapse
      ScanView.swift           # REPLACE Phase 1 version — header + list
  ContentView.swift            # REPLACE Phase 1 version — sidebar navigation
  App/
    AppState.swift             # MODIFY — add healthScore computed property
```

---

## Task 1: DesignTokens.swift

**Files:**
- Create: `Mend/Resources/DesignTokens.swift`

- [ ] **Step 1: Create the file**

```swift
// Mend/Resources/DesignTokens.swift
import SwiftUI

enum DesignTokens {

    // MARK: - Accent (Teal)

    static func accentPrimary(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(hex: "#2dd4bf") : Color(hex: "#0d9488")
    }

    static func accentSubtle(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(hex: "#2dd4bf").opacity(0.10)
            : Color(hex: "#0d9488").opacity(0.10)
    }

    static var accentGradient: LinearGradient {
        LinearGradient(
            colors: [Color(hex: "#0d9488"), Color(hex: "#2dd4bf")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: - Status

    static let statusOK    = Color(hex: "#22c55e")
    static let statusWarn  = Color(hex: "#f59e0b")
    static let statusError = Color(hex: "#ef4444")
    static func statusUnavailable(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(hex: "#334155") : Color(hex: "#94a3b8")
    }

    // MARK: - Text

    static func textPrimary(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(hex: "#f1f5f9") : Color(hex: "#0f172a")
    }

    static func textSecondary(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(hex: "#334155") : Color(hex: "#94a3b8")
    }

    static let textNavInactive = Color(hex: "#64748b")

    // MARK: - Surfaces

    static func windowBackground(_ scheme: ColorScheme) -> LinearGradient {
        if scheme == .dark {
            return LinearGradient(
                colors: [Color(hex: "#021a18"), Color(hex: "#041a24"), Color(hex: "#050d1a")],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        }
        return LinearGradient(
            colors: [Color(hex: "#f0fdfa"), Color(hex: "#ecfdf5"), Color(hex: "#f0f9ff")],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
    }

    static func sidebarBackground(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color.white.opacity(0.03)
            : Color.white.opacity(0.50)
    }

    static func cardSurface(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color.white.opacity(0.04)
            : Color.white.opacity(0.65)
    }

    static func cardBorderOK(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(hex: "#2dd4bf").opacity(0.10)
            : Color.white.opacity(0.95)
    }

    static func cardBorderWarn(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(hex: "#f59e0b").opacity(0.18)
            : Color(hex: "#fef3c7").opacity(0.90)
    }

    static func sidebarDivider(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(hex: "#2dd4bf").opacity(0.10)
            : Color(hex: "#ccfbf1").opacity(0.80)
    }

    static func rowSeparator(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(hex: "#2dd4bf").opacity(0.08)
            : Color(hex: "#e2f8f5").opacity(0.70)
    }

    // MARK: - Spacing

    static let sidebarWidth:     CGFloat = 130
    static let cardCornerRadius: CGFloat = 14
    static let cardPadding:      CGFloat = 16
    static let cardGridGap:      CGFloat = 10
    static let heroCornerRadius: CGFloat = 18
    static let navItemRadius:    CGFloat = 8
}

// MARK: - Color(hex:) helper

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >>  8) & 0xFF) / 255
        let b = Double( int        & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
```

- [ ] **Step 2: Confirm it compiles (no test needed — pure constants)**

Open Xcode → `⌘B`. Expected: Build Succeeded.

- [ ] **Step 3: Commit**

```bash
git add Mend/Resources/DesignTokens.swift
git commit -m "feat: add DesignTokens color/spacing system"
```

---

## Task 2: StatusDotView

**Files:**
- Create: `Mend/Shared/StatusDotView.swift`
- Create: `MendTests/StatusDotViewTests.swift`

- [ ] **Step 1: Write the failing test**

```swift
// MendTests/StatusDotViewTests.swift
import XCTest
@testable import Mend

final class StatusDotViewTests: XCTestCase {
    func test_statusColor_ok() {
        XCTAssertEqual(StatusDotView.color(for: .ok, scheme: .light), DesignTokens.statusOK)
    }
    func test_statusColor_warn() {
        XCTAssertEqual(StatusDotView.color(for: .warn, scheme: .light), DesignTokens.statusWarn)
    }
    func test_statusColor_error() {
        XCTAssertEqual(StatusDotView.color(for: .error, scheme: .light), DesignTokens.statusError)
    }
}
```

- [ ] **Step 2: Run test to confirm it fails**

`⌘U` in Xcode. Expected: compile error — `StatusDotView` not found.

- [ ] **Step 3: Implement**

```swift
// Mend/Shared/StatusDotView.swift
import SwiftUI

struct StatusDotView: View {
    let status: ModuleStatus
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        Circle()
            .fill(Self.color(for: status, scheme: scheme))
            .frame(width: 6, height: 6)
            .shadow(color: Self.color(for: status, scheme: scheme).opacity(scheme == .dark ? 0.70 : 0.50),
                    radius: 3)
    }

    static func color(for status: ModuleStatus, scheme: ColorScheme) -> Color {
        switch status {
        case .ok:          return DesignTokens.statusOK
        case .warn:        return DesignTokens.statusWarn
        case .error:       return DesignTokens.statusError
        case .unavailable: return DesignTokens.statusUnavailable(scheme)
        }
    }
}
```

- [ ] **Step 4: Run tests — expect PASS**

- [ ] **Step 5: Commit**

```bash
git add Mend/Shared/StatusDotView.swift MendTests/StatusDotViewTests.swift
git commit -m "feat: add StatusDotView with glowing teal/amber/red dots"
```

---

## Task 3: ScanIconView (Lucide SVG icons)

**Files:**
- Create: `Mend/Shared/ScanIconView.swift`

Each icon is a SwiftUI `Path` drawn from a Lucide SVG path string, scaled to 15×15.

- [ ] **Step 1: Create the file**

```swift
// Mend/Shared/ScanIconView.swift
import SwiftUI

enum ScanIcon: String, CaseIterable {
    case overview, scan, clean, apps, updates, startup, storage
    case identity, battery, thermal, memory, processes, docker, timemachine, wifi, security, agents, ssd, brew
}

struct ScanIconView: View {
    let icon: ScanIcon
    var size: CGFloat = 15
    var color: Color = DesignTokens.textNavInactive

    var body: some View {
        iconShape
            .stroke(color, style: StrokeStyle(lineWidth: 1.75, lineCap: .round, lineJoin: .round))
            .frame(width: size, height: size)
    }

    @ViewBuilder
    private var iconShape: some View {
        switch icon {
        case .overview:
            // grid-2×2  (24px canvas scaled to `size`)
            IconPath { p in
                let s = size / 24
                p.addRect(CGRect(x: 3*s, y: 3*s, width: 7*s, height: 7*s))
                p.addRect(CGRect(x: 14*s, y: 3*s, width: 7*s, height: 7*s))
                p.addRect(CGRect(x: 3*s, y: 14*s, width: 7*s, height: 7*s))
                p.addRect(CGRect(x: 14*s, y: 14*s, width: 7*s, height: 7*s))
            }
        case .scan:
            // activity / waveform
            IconPath { p in
                let s = size / 24
                p.move(to:    CGPoint(x: 2*s,  y: 12*s))
                p.addLine(to: CGPoint(x: 6*s,  y: 12*s))
                p.addLine(to: CGPoint(x: 9*s,  y: 3*s))
                p.addLine(to: CGPoint(x: 15*s, y: 21*s))
                p.addLine(to: CGPoint(x: 18*s, y: 12*s))
                p.addLine(to: CGPoint(x: 22*s, y: 12*s))
            }
        case .clean:
            // trash-2
            IconPath { p in
                let s = size / 24
                p.move(to: CGPoint(x: 3*s, y: 6*s)); p.addLine(to: CGPoint(x: 21*s, y: 6*s))
                p.move(to: CGPoint(x: 19*s, y: 6*s))
                p.addLine(to: CGPoint(x: 17.7*s, y: 19.1*s))
                p.addArc(center: CGPoint(x: 16.7*s, y: 19.7*s), radius: 0.5*s, startAngle: .degrees(0), endAngle: .degrees(360), clockwise: false)
                p.addLine(to: CGPoint(x: 7.3*s, y: 19.7*s))
                p.addLine(to: CGPoint(x: 5*s, y: 6*s))
                p.move(to: CGPoint(x: 8*s, y: 6*s)); p.addLine(to: CGPoint(x: 8*s, y: 4*s))
                p.addLine(to: CGPoint(x: 16*s, y: 4*s)); p.addLine(to: CGPoint(x: 16*s, y: 6*s))
            }
        case .apps:
            // monitor
            IconPath { p in
                let s = size / 24
                let rect = CGRect(x: 2*s, y: 3*s, width: 20*s, height: 14*s)
                p.addRoundedRect(in: rect, cornerSize: CGSize(width: 2*s, height: 2*s))
                p.move(to: CGPoint(x: 8*s, y: 21*s)); p.addLine(to: CGPoint(x: 16*s, y: 21*s))
                p.move(to: CGPoint(x: 12*s, y: 17*s)); p.addLine(to: CGPoint(x: 12*s, y: 21*s))
            }
        case .updates:
            // arrow-down-circle
            IconPath { p in
                let s = size / 24
                p.addEllipse(in: CGRect(x: 2*s, y: 2*s, width: 20*s, height: 20*s))
                p.move(to: CGPoint(x: 12*s, y: 8*s)); p.addLine(to: CGPoint(x: 12*s, y: 16*s))
                p.move(to: CGPoint(x: 8*s, y: 12*s)); p.addLine(to: CGPoint(x: 12*s, y: 16*s))
                p.addLine(to: CGPoint(x: 16*s, y: 12*s))
            }
        case .startup:
            // radio / circle + waves
            IconPath { p in
                let s = size / 24
                p.addEllipse(in: CGRect(x: 9*s, y: 9*s, width: 6*s, height: 6*s))
                p.move(to: CGPoint(x: 4.93*s, y: 4.93*s))
                p.addQuadCurve(to: CGPoint(x: 4.93*s, y: 19.07*s), control: CGPoint(x: -1*s, y: 12*s))
                p.move(to: CGPoint(x: 19.07*s, y: 4.93*s))
                p.addQuadCurve(to: CGPoint(x: 19.07*s, y: 19.07*s), control: CGPoint(x: 25*s, y: 12*s))
            }
        case .storage:
            // database
            IconPath { p in
                let s = size / 24
                p.addEllipse(in: CGRect(x: 3*s, y: 2*s, width: 18*s, height: 6*s))
                p.move(to: CGPoint(x: 21*s, y: 5*s))
                p.addLine(to: CGPoint(x: 21*s, y: 19*s))
                p.addQuadCurve(to: CGPoint(x: 3*s, y: 19*s), control: CGPoint(x: 12*s, y: 24*s))
                p.addLine(to: CGPoint(x: 3*s, y: 5*s))
                p.move(to: CGPoint(x: 3*s, y: 12*s))
                p.addQuadCurve(to: CGPoint(x: 21*s, y: 12*s), control: CGPoint(x: 12*s, y: 17*s))
            }
        // Module icons (used in ScanRowView)
        case .identity:
            IconPath { p in
                let s = size / 24
                p.addRoundedRect(in: CGRect(x: 2*s, y: 3*s, width: 20*s, height: 14*s),
                                 cornerSize: CGSize(width: 2*s, height: 2*s))
                p.move(to: CGPoint(x: 8*s, y: 21*s)); p.addLine(to: CGPoint(x: 16*s, y: 21*s))
                p.move(to: CGPoint(x: 12*s, y: 17*s)); p.addLine(to: CGPoint(x: 12*s, y: 21*s))
            }
        case .battery:
            IconPath { p in
                let s = size / 24
                p.addRoundedRect(in: CGRect(x: 1*s, y: 7*s, width: 18*s, height: 10*s),
                                 cornerSize: CGSize(width: 2*s, height: 2*s))
                p.move(to: CGPoint(x: 23*s, y: 11*s)); p.addLine(to: CGPoint(x: 23*s, y: 13*s))
            }
        case .thermal:
            IconPath { p in
                let s = size / 24
                p.move(to: CGPoint(x: 14*s, y: 14.76*s))
                p.addLine(to: CGPoint(x: 14*s, y: 3.5*s))
                p.addQuadCurve(to: CGPoint(x: 10*s, y: 3.5*s), control: CGPoint(x: 12*s, y: 1*s))
                p.addLine(to: CGPoint(x: 10*s, y: 14.76*s))
                p.addArc(center: CGPoint(x: 12*s, y: 19*s), radius: 4.5*s,
                         startAngle: .degrees(210), endAngle: .degrees(330), clockwise: false)
                p.closeSubpath()
            }
        case .memory:
            IconPath { p in
                let s = size / 24
                p.addRoundedRect(in: CGRect(x: 2*s, y: 8*s, width: 20*s, height: 8*s),
                                 cornerSize: CGSize(width: 2*s, height: 2*s))
                for x in [6, 10, 14, 18] {
                    let cx = CGFloat(x) * s
                    p.move(to: CGPoint(x: cx, y: 8*s)); p.addLine(to: CGPoint(x: cx, y: 6*s))
                    p.move(to: CGPoint(x: cx, y: 16*s)); p.addLine(to: CGPoint(x: cx, y: 18*s))
                }
            }
        case .processes:
            IconPath { p in
                let s = size / 24
                p.addRoundedRect(in: CGRect(x: 4*s, y: 4*s, width: 16*s, height: 16*s),
                                 cornerSize: CGSize(width: 2*s, height: 2*s))
                p.addEllipse(in: CGRect(x: 9*s, y: 9*s, width: 6*s, height: 6*s))
            }
        case .docker:
            IconPath { p in
                let s = size / 24
                p.addRoundedRect(in: CGRect(x: 2*s, y: 3*s, width: 20*s, height: 14*s),
                                 cornerSize: CGSize(width: 2*s, height: 2*s))
                p.move(to: CGPoint(x: 2*s, y: 20*s)); p.addLine(to: CGPoint(x: 22*s, y: 20*s))
            }
        case .timemachine:
            IconPath { p in
                let s = size / 24
                p.addEllipse(in: CGRect(x: 2*s, y: 2*s, width: 20*s, height: 20*s))
                p.move(to: CGPoint(x: 12*s, y: 6*s)); p.addLine(to: CGPoint(x: 12*s, y: 12*s))
                p.addLine(to: CGPoint(x: 16*s, y: 14*s))
            }
        case .wifi:
            IconPath { p in
                let s = size / 24
                p.move(to: CGPoint(x: 5*s, y: 12.55*s))
                p.addQuadCurve(to: CGPoint(x: 19.08*s, y: 12.55*s), control: CGPoint(x: 12*s, y: 7*s))
                p.move(to: CGPoint(x: 1.42*s, y: 9*s))
                p.addQuadCurve(to: CGPoint(x: 22.58*s, y: 9*s), control: CGPoint(x: 12*s, y: 3*s))
                p.move(to: CGPoint(x: 8.53*s, y: 16.11*s))
                p.addQuadCurve(to: CGPoint(x: 15.47*s, y: 16.11*s), control: CGPoint(x: 12*s, y: 12*s))
                p.addEllipse(in: CGRect(x: 11*s, y: 19*s, width: 2*s, height: 2*s))
            }
        case .security:
            IconPath { p in
                let s = size / 24
                p.move(to: CGPoint(x: 12*s, y: 22*s))
                p.addQuadCurve(to: CGPoint(x: 12*s, y: 2*s), control: CGPoint(x: 20*s, y: 18*s))
                p.addLine(to: CGPoint(x: 4*s, y: 5*s))
                p.addLine(to: CGPoint(x: 4*s, y: 12*s))
                p.addQuadCurve(to: CGPoint(x: 12*s, y: 22*s), control: CGPoint(x: 4*s, y: 18*s))
            }
        case .agents:
            IconPath { p in
                let s = size / 24
                p.addEllipse(in: CGRect(x: 9*s, y: 9*s, width: 6*s, height: 6*s))
                p.addEllipse(in: CGRect(x: 2*s, y: 2*s, width: 6*s, height: 6*s))
                p.addEllipse(in: CGRect(x: 16*s, y: 2*s, width: 6*s, height: 6*s))
                p.addEllipse(in: CGRect(x: 16*s, y: 16*s, width: 6*s, height: 6*s))
                p.addEllipse(in: CGRect(x: 2*s, y: 16*s, width: 6*s, height: 6*s))
            }
        case .ssd:
            IconPath { p in
                let s = size / 24
                p.addRoundedRect(in: CGRect(x: 2*s, y: 6*s, width: 20*s, height: 12*s),
                                 cornerSize: CGSize(width: 2*s, height: 2*s))
                p.addEllipse(in: CGRect(x: 15*s, y: 10*s, width: 4*s, height: 4*s))
                p.move(to: CGPoint(x: 6*s, y: 10*s)); p.addLine(to: CGPoint(x: 6*s, y: 14*s))
                p.move(to: CGPoint(x: 9*s, y: 10*s)); p.addLine(to: CGPoint(x: 9*s, y: 14*s))
            }
        case .brew:
            IconPath { p in
                let s = size / 24
                p.addRoundedRect(in: CGRect(x: 3*s, y: 2*s, width: 18*s, height: 20*s),
                                 cornerSize: CGSize(width: 3*s, height: 3*s))
                p.move(to: CGPoint(x: 9*s, y: 12*s)); p.addLine(to: CGPoint(x: 15*s, y: 12*s))
            }
        }
    }
}

// MARK: - IconPath helper

private struct IconPath: Shape {
    let build: (inout Path) -> Void
    func path(in rect: CGRect) -> Path {
        var p = Path()
        build(&p)
        return p
    }
}
```

- [ ] **Step 2: Build (`⌘B`) — confirm no errors**

- [ ] **Step 3: Commit**

```bash
git add Mend/Shared/ScanIconView.swift
git commit -m "feat: add ScanIconView with Lucide SVG paths for all modules"
```

---

## Task 4: HealthRingView

**Files:**
- Create: `Mend/Shared/HealthRingView.swift`
- Create: `MendTests/HealthRingViewTests.swift`

- [ ] **Step 1: Write the failing test**

```swift
// MendTests/HealthRingViewTests.swift
import XCTest
@testable import Mend

final class HealthRingViewTests: XCTestCase {
    func test_strokeFraction_fullScore() {
        XCTAssertEqual(HealthRingView.strokeFraction(for: 100), 1.0, accuracy: 0.001)
    }
    func test_strokeFraction_zero() {
        XCTAssertEqual(HealthRingView.strokeFraction(for: 0), 0.0, accuracy: 0.001)
    }
    func test_strokeFraction_midScore() {
        XCTAssertEqual(HealthRingView.strokeFraction(for: 85), 0.85, accuracy: 0.001)
    }
}
```

- [ ] **Step 2: Run — confirm FAIL**

- [ ] **Step 3: Implement**

```swift
// Mend/Shared/HealthRingView.swift
import SwiftUI

struct HealthRingView: View {
    let score: Int                      // 0–100
    var size: CGFloat = 80
    @State private var animatedFraction: CGFloat = 0

    var body: some View {
        ZStack {
            // Track
            Circle()
                .stroke(DesignTokens.accentGradient.opacity(0.15), lineWidth: 8)

            // Progress
            Circle()
                .trim(from: 0, to: animatedFraction)
                .stroke(
                    DesignTokens.accentGradient,
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 0.4), value: animatedFraction)

            // Score label
            VStack(spacing: 0) {
                Text("\(score)")
                    .font(.system(size: 18, weight: .bold, design: .default))
                    .tracking(-1)
                Text("score")
                    .font(.system(size: 7, weight: .regular))
                    .tracking(0.5)
                    .textCase(.uppercase)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: size, height: size)
        .onAppear {
            animatedFraction = Self.strokeFraction(for: score)
        }
        .onChange(of: score) { _, new in
            animatedFraction = Self.strokeFraction(for: new)
        }
    }

    static func strokeFraction(for score: Int) -> CGFloat {
        CGFloat(max(0, min(100, score))) / 100
    }
}
```

- [ ] **Step 4: Run tests — expect PASS**

- [ ] **Step 5: Commit**

```bash
git add Mend/Shared/HealthRingView.swift MendTests/HealthRingViewTests.swift
git commit -m "feat: add HealthRingView with animated teal gradient stroke"
```

---

## Task 5: AppState — healthScore

**Files:**
- Modify: `Mend/App/AppState.swift`
- Modify: `MendTests/AppStateTests.swift`

- [ ] **Step 1: Write the failing test** (add to existing test file)

```swift
// MendTests/AppStateTests.swift — add these cases
func test_healthScore_allOK() {
    let results: ScanResults = [
        "battery": ModuleResult(status: .ok, value: "97%", message: ""),
        "storage": ModuleResult(status: .ok, value: "50%", message: ""),
    ]
    let state = AppState()
    state.results = results
    XCTAssertEqual(state.healthScore, 100)
}

func test_healthScore_oneWarn() {
    let results: ScanResults = [
        "battery": ModuleResult(status: .ok,   value: "97%", message: ""),
        "storage": ModuleResult(status: .warn,  value: "80%", message: ""),
    ]
    let state = AppState()
    state.results = results
    XCTAssertEqual(state.healthScore, 80)  // (100 + 60) / 2
}

func test_healthScore_unavailableIgnored() {
    let results: ScanResults = [
        "battery":  ModuleResult(status: .ok,          value: "97%", message: ""),
        "docker":   ModuleResult(status: .unavailable, value: "",    message: ""),
    ]
    let state = AppState()
    state.results = results
    XCTAssertEqual(state.healthScore, 100)  // unavailable excluded from avg
}
```

- [ ] **Step 2: Run — confirm FAIL**

- [ ] **Step 3: Add `healthScore` to AppState**

```swift
// In AppState.swift, add inside the class:
var healthScore: Int {
    let scored = results.values.filter { $0.status != .unavailable }
    guard !scored.isEmpty else { return 100 }
    let total = scored.reduce(0) { acc, r in
        switch r.status {
        case .ok:    return acc + 100
        case .warn:  return acc + 60
        case .error: return acc + 0
        case .unavailable: return acc
        }
    }
    return total / scored.count
}
```

- [ ] **Step 4: Run tests — expect PASS**

- [ ] **Step 5: Commit**

```bash
git add Mend/App/AppState.swift MendTests/AppStateTests.swift
git commit -m "feat: add healthScore computed property to AppState"
```

---

## Task 6: HeroCardView

**Files:**
- Create: `Mend/Features/Overview/HeroCardView.swift`

- [ ] **Step 1: Create the file**

```swift
// Mend/Features/Overview/HeroCardView.swift
import SwiftUI

struct HeroCardView: View {
    let score: Int
    let warningCount: Int
    let errorCount: Int
    let isScanning: Bool
    let onScan: () -> Void

    @Environment(\.colorScheme) private var scheme

    private var statusLabel: String {
        if errorCount > 0 { return "Issues Detected" }
        if warningCount > 0 { return "Needs Attention" }
        return "System Healthy"
    }

    private var statusDetail: String {
        if errorCount > 0 { return "Your Mac needs attention." }
        if warningCount > 0 { return "Some items need your attention." }
        return "Your Mac is in good shape."
    }

    var body: some View {
        HStack(spacing: 24) {
            HealthRingView(score: score)

            VStack(alignment: .leading, spacing: 4) {
                Text(statusLabel)
                    .font(.system(size: 11, weight: .bold))
                    .tracking(2)
                    .textCase(.uppercase)
                    .foregroundStyle(DesignTokens.accentPrimary(scheme))

                Text(statusDetail)
                    .font(.system(size: 20, weight: .light))
                    .tracking(-0.5)
                    .foregroundStyle(DesignTokens.textPrimary(scheme))

                Text("\(warningCount) warning\(warningCount == 1 ? "" : "s") · \(errorCount) error\(errorCount == 1 ? "" : "s")")
                    .font(.system(size: 11))
                    .foregroundStyle(DesignTokens.textSecondary(scheme))
            }

            Spacer()

            Button(action: onScan) {
                if isScanning {
                    ProgressView()
                        .scaleEffect(0.8)
                        .frame(width: 60)
                } else {
                    Text("Scan Now")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white)
                }
            }
            .buttonStyle(TealGradientButtonStyle())
            .disabled(isScanning)
        }
        .padding(DesignTokens.cardPadding + 8)
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.heroCornerRadius)
                .fill(DesignTokens.cardSurface(scheme))
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: DesignTokens.heroCornerRadius))
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.heroCornerRadius)
                .stroke(DesignTokens.cardBorderOK(scheme), lineWidth: 1)
        )
        .shadow(color: DesignTokens.accentPrimary(scheme).opacity(0.08), radius: 12, x: 0, y: 4)
    }
}

// MARK: - Button style

struct TealGradientButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(DesignTokens.accentGradient)
                    .shadow(color: Color(hex: "#0d9488").opacity(0.35), radius: 8, x: 0, y: 3)
            )
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}
```

- [ ] **Step 2: Build (`⌘B`) — no errors**

- [ ] **Step 3: Commit**

```bash
git add Mend/Features/Overview/HeroCardView.swift
git commit -m "feat: add HeroCardView with health ring and scan button"
```

---

## Task 7: MetricCard

Replace the Phase 1 MetricCard with the glass design.

**Files:**
- Replace: `Mend/Features/Overview/MetricCard.swift`

- [ ] **Step 1: Replace the file entirely**

```swift
// Mend/Features/Overview/MetricCard.swift
import SwiftUI

struct MetricCard: View {
    let module: String          // display name, e.g. "Battery"
    let result: ModuleResult
    let progress: CGFloat?      // 0.0–1.0, nil if not applicable

    @Environment(\.colorScheme) private var scheme

    var border: Color {
        result.status == .warn || result.status == .error
            ? DesignTokens.cardBorderWarn(scheme)
            : DesignTokens.cardBorderOK(scheme)
    }

    var progressColor: Color {
        result.status == .warn ? DesignTokens.statusWarn : DesignTokens.accentPrimary(scheme)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Header: label + dot
            HStack {
                Text(module.uppercased())
                    .font(.system(size: 9, weight: .bold))
                    .tracking(1.5)
                    .foregroundStyle(DesignTokens.textSecondary(scheme))
                Spacer()
                StatusDotView(status: result.status)
                    .transition(.scale.animation(.easeOut(duration: 0.2)))
            }
            .padding(.bottom, 10)

            // Value
            Text(result.value)
                .font(.system(size: 28, weight: .light))
                .tracking(-1)
                .foregroundStyle(DesignTokens.textPrimary(scheme))
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            // Detail
            if !result.message.isEmpty {
                Text(result.message)
                    .font(.system(size: 10))
                    .foregroundStyle(DesignTokens.textSecondary(scheme))
                    .padding(.top, 6)
            }

            // Progress bar
            if let progress {
                GeometryReader { _ in
                    ZStack(alignment: .leading) {
                        Capsule().fill(progressColor.opacity(0.12)).frame(height: 3)
                        Capsule().fill(progressColor).frame(width: max(3, progress * 200), height: 3)
                    }
                }
                .frame(height: 3)
                .padding(.top, 8)
            }
        }
        .padding(DesignTokens.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.cardCornerRadius)
                .fill(DesignTokens.cardSurface(scheme))
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: DesignTokens.cardCornerRadius))
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.cardCornerRadius)
                .stroke(border, lineWidth: 1)
        )
        .shadow(color: DesignTokens.accentPrimary(scheme).opacity(0.06), radius: 8, x: 0, y: 2)
    }
}
```

- [ ] **Step 2: Build (`⌘B`) — no errors**

- [ ] **Step 3: Commit**

```bash
git add Mend/Features/Overview/MetricCard.swift
git commit -m "feat: replace MetricCard with glass design — teal tokens, progress bar, glow"
```

---

## Task 8: OverviewView

**Files:**
- Replace: `Mend/Features/Overview/OverviewView.swift`

- [ ] **Step 1: Replace the file**

```swift
// Mend/Features/Overview/OverviewView.swift
import SwiftUI

// Modules shown as metric cards and their progress extraction logic
private let overviewModules: [(key: String, label: String, progressKey: String?)] = [
    ("battery",     "Battery",     "battery"),
    ("storage",     "Storage",     "storage"),
    ("memory",      "Memory",      nil),
    ("thermal",     "Thermal",     nil),
    ("brew",        "Homebrew",    nil),
    ("timemachine", "Backup",      nil),
    ("updates",     "Updates",     nil),
    ("security",    "Security",    nil),
    ("wifi",        "Wi-Fi",       nil),
]

struct OverviewView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.colorScheme) private var scheme

    private var warningCount: Int {
        appState.results.values.filter { $0.status == .warn }.count
    }
    private var errorCount: Int {
        appState.results.values.filter { $0.status == .error }.count
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                HeroCardView(
                    score: appState.healthScore,
                    warningCount: warningCount,
                    errorCount: errorCount,
                    isScanning: appState.isScanning,
                    onScan: { Task { await appState.scan() } }
                )

                LazyVGrid(
                    columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())],
                    spacing: DesignTokens.cardGridGap
                ) {
                    ForEach(overviewModules, id: \.key) { item in
                        if let result = appState.results[item.key] {
                            MetricCard(
                                module: item.label,
                                result: result,
                                progress: progressValue(for: item.key, result: result)
                            )
                        }
                    }
                }
            }
            .padding(16)
        }
    }

    private func progressValue(for key: String, result: ModuleResult) -> CGFloat? {
        switch key {
        case "battery":
            guard let pct = Float(result.value.replacingOccurrences(of: "%", with: "")) else { return nil }
            return CGFloat(pct / 100)
        case "storage":
            guard let pct = Float(result.value.replacingOccurrences(of: "%", with: "")) else { return nil }
            return CGFloat(pct / 100)
        default:
            return nil
        }
    }
}
```

- [ ] **Step 2: Build (`⌘B`) — no errors**

- [ ] **Step 3: Commit**

```bash
git add Mend/Features/Overview/OverviewView.swift
git commit -m "feat: replace OverviewView with hero + glass grid layout"
```

---

## Task 9: ScanRowView

**Files:**
- Replace: `Mend/Features/Scan/ScanRowView.swift`

- [ ] **Step 1: Replace the file**

```swift
// Mend/Features/Scan/ScanRowView.swift
import SwiftUI

let allModules: [(key: String, label: String, icon: ScanIcon)] = [
    ("identity",    "Identity",    .identity),
    ("battery",     "Battery",     .battery),
    ("storage",     "Storage",     .storage),
    ("ssd",         "SSD",         .ssd),
    ("memory",      "Memory",      .memory),
    ("thermal",     "Thermal",     .thermal),
    ("processes",   "Processes",   .processes),
    ("brew",        "Homebrew",    .brew),
    ("docker",      "Docker",      .docker),
    ("timemachine", "Time Machine",.timemachine),
    ("updates",     "Updates",     .updates),
    ("wifi",        "Wi-Fi",       .wifi),
    ("security",    "Security",    .security),
    ("agents",      "Agents",      .agents),
]

struct ScanRowView: View {
    let module: String
    let label: String
    let icon: ScanIcon
    let result: ModuleResult

    @State private var isExpanded = false
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Main row
            HStack(spacing: 12) {
                ScanIconView(icon: icon, color: DesignTokens.textSecondary(scheme))

                Text(label)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(DesignTokens.textPrimary(scheme))

                Spacer()

                Text(result.value)
                    .font(.system(size: 11).monospacedDigit())
                    .foregroundStyle(DesignTokens.textSecondary(scheme))

                StatusDotView(status: result.status)

                if !result.message.isEmpty {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(DesignTokens.textSecondary(scheme).opacity(0.6))
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .animation(.easeInOut(duration: 0.15), value: isExpanded)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
            .background(
                result.status == .warn
                    ? DesignTokens.statusWarn.opacity(0.025)
                    : Color.clear
            )
            .contentShape(Rectangle())
            .onTapGesture {
                guard !result.message.isEmpty else { return }
                withAnimation(.easeInOut(duration: 0.15)) { isExpanded.toggle() }
            }

            // Expanded detail
            if isExpanded && !result.message.isEmpty {
                Text(result.message)
                    .font(.system(size: 10))
                    .foregroundStyle(DesignTokens.textSecondary(scheme))
                    .padding(.leading, 43)
                    .padding(.trailing, 16)
                    .padding(.bottom, 12)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}
```

- [ ] **Step 2: Build (`⌘B`) — no errors**

- [ ] **Step 3: Commit**

```bash
git add Mend/Features/Scan/ScanRowView.swift
git commit -m "feat: replace ScanRowView with SVG icons, expand/collapse, glow dots"
```

---

## Task 10: ScanView

**Files:**
- Replace: `Mend/Features/Scan/ScanView.swift`

- [ ] **Step 1: Replace the file**

```swift
// Mend/Features/Scan/ScanView.swift
import SwiftUI

struct ScanView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.colorScheme) private var scheme

    private var warningCount: Int {
        appState.results.values.filter { $0.status == .warn }.count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Full Scan")
                        .font(.system(size: 16, weight: .semibold))
                        .tracking(-0.3)
                        .foregroundStyle(DesignTokens.textPrimary(scheme))
                    Text("\(allModules.count) modules · \(warningCount) warning\(warningCount == 1 ? "" : "s")")
                        .font(.system(size: 11))
                        .foregroundStyle(DesignTokens.textSecondary(scheme))
                }
                Spacer()
                Button("Rescan") {
                    Task { await appState.scan() }
                }
                .buttonStyle(TealGradientButtonStyle())
                .disabled(appState.isScanning)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)

            // List
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(allModules, id: \.key) { item in
                        if let result = appState.results[item.key] {
                            ScanRowView(
                                module: item.key,
                                label: item.label,
                                icon: item.icon,
                                result: result
                            )
                            Divider()
                                .background(DesignTokens.rowSeparator(scheme))
                                .padding(.leading, 43)
                        }
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: DesignTokens.cardCornerRadius)
                        .fill(DesignTokens.cardSurface(scheme))
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: DesignTokens.cardCornerRadius))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: DesignTokens.cardCornerRadius)
                        .stroke(DesignTokens.cardBorderOK(scheme), lineWidth: 1)
                )
                .padding(.horizontal, 20)
                .shadow(color: DesignTokens.accentPrimary(scheme).opacity(0.06), radius: 8, x: 0, y: 2)
            }
        }
    }
}
```

- [ ] **Step 2: Build (`⌘B`) — no errors**

- [ ] **Step 3: Commit**

```bash
git add Mend/Features/Scan/ScanView.swift
git commit -m "feat: replace ScanView with glass list container and header"
```

---

## Task 11: ContentView — Sidebar Navigation

Replace the Phase 1 tab bar with the full-width sidebar.

**Files:**
- Replace: `Mend/ContentView.swift`

- [ ] **Step 1: Replace the file**

```swift
// Mend/ContentView.swift
import SwiftUI

enum MendTab: String, CaseIterable {
    case overview, scan, clean, apps, updates, startup, storage

    var label: String {
        switch self {
        case .overview: return "Overview"
        case .scan:     return "Scan"
        case .clean:    return "Clean"
        case .apps:     return "Apps"
        case .updates:  return "Updates"
        case .startup:  return "Startup"
        case .storage:  return "Storage"
        }
    }

    var icon: ScanIcon {
        switch self {
        case .overview: return .overview
        case .scan:     return .scan
        case .clean:    return .clean
        case .apps:     return .apps
        case .updates:  return .updates
        case .startup:  return .startup
        case .storage:  return .storage
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab: MendTab = .overview
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        HStack(spacing: 0) {
            // Sidebar
            SidebarView(selectedTab: $selectedTab)
                .frame(width: DesignTokens.sidebarWidth)

            Divider()
                .background(DesignTokens.sidebarDivider(scheme))

            // Content
            ZStack {
                DesignTokens.windowBackground(scheme).ignoresSafeArea()

                switch selectedTab {
                case .overview: OverviewView()
                case .scan:     ScanView()
                default:
                    Text("\(selectedTab.label) — coming soon")
                        .foregroundStyle(DesignTokens.textSecondary(scheme))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(minWidth: 860, minHeight: 600)
    }
}

// MARK: - Sidebar

private struct SidebarView: View {
    @Binding var selectedTab: MendTab
    @EnvironmentObject var appState: AppState
    @Environment(\.colorScheme) private var scheme

    private var lastScannedLabel: String {
        guard let date = appState.lastScanned else { return "Not yet scanned" }
        let diff = Int(Date().timeIntervalSince(date) / 60)
        return diff < 1 ? "Just now" : "\(diff)m ago"
    }

    private var updatesBadge: Int {
        guard let r = appState.results["updates"], r.status == .warn,
              let n = Int(r.value) else { return 0 }
        return n
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Logo
            HStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(DesignTokens.accentGradient)
                    .frame(width: 22, height: 22)
                    .shadow(color: DesignTokens.accentPrimary(scheme).opacity(0.35), radius: 4)

                Text("Mend")
                    .font(.system(size: 13, weight: .bold))
                    .tracking(-0.3)
                    .foregroundStyle(DesignTokens.textPrimary(scheme))
            }
            .padding(.horizontal, 14)
            .padding(.top, 18)
            .padding(.bottom, 14)

            Divider().background(DesignTokens.sidebarDivider(scheme))

            // Nav items
            VStack(spacing: 1) {
                ForEach(MendTab.allCases, id: \.self) { tab in
                    NavItemView(
                        tab: tab,
                        isSelected: selectedTab == tab,
                        badge: tab == .updates ? updatesBadge : 0
                    ) {
                        selectedTab = tab
                    }
                }
            }
            .padding(8)

            Spacer()

            Divider().background(DesignTokens.sidebarDivider(scheme))

            Text(lastScannedLabel)
                .font(.system(size: 9))
                .foregroundStyle(DesignTokens.textSecondary(scheme))
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
        }
        .background(DesignTokens.sidebarBackground(scheme))
        .background(.ultraThinMaterial)
    }
}

// MARK: - Nav item

private struct NavItemView: View {
    let tab: MendTab
    let isSelected: Bool
    let badge: Int
    let action: () -> Void
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                ScanIconView(
                    icon: tab.icon,
                    color: isSelected
                        ? DesignTokens.accentPrimary(scheme)
                        : DesignTokens.textNavInactive
                )

                Text(tab.label)
                    .font(.system(size: 11, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(
                        isSelected
                            ? DesignTokens.accentPrimary(scheme)
                            : DesignTokens.textNavInactive
                    )

                Spacer()

                if badge > 0 {
                    Text("\(badge)")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 1)
                        .background(Capsule().fill(DesignTokens.statusWarn))
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(
                isSelected
                    ? RoundedRectangle(cornerRadius: DesignTokens.navItemRadius)
                        .fill(DesignTokens.accentSubtle(scheme))
                    : nil
            )
        }
        .buttonStyle(.plain)
    }
}
```

- [ ] **Step 2: Build (`⌘B`) — no errors**

- [ ] **Step 3: Run the app (`⌘R`) — verify:**
  - Sidebar appears on the left with all 7 items
  - Overview is selected by default with teal highlight
  - Clicking Scan switches to ScanView
  - Both light and dark mode look correct (toggle in System Preferences)

- [ ] **Step 4: Commit**

```bash
git add Mend/ContentView.swift
git commit -m "feat: replace tab bar with full-width sidebar navigation"
```

---

## Task 12: Window background + dark mode wiring

**Files:**
- Modify: `Mend/App/MendApp.swift`

- [ ] **Step 1: Set window style and background**

```swift
// In MendApp.swift, update the WindowGroup:
WindowGroup {
    ContentView()
        .environmentObject(appState)
}
.windowStyle(.hiddenTitleBar)
.defaultSize(width: 900, height: 640)
```

- [ ] **Step 2: Build and run in both appearances**

Toggle System Preferences → Appearance → Dark. Verify:
- Window background is deep teal-dark gradient
- Cards are near-transparent with teal border tint
- Teal accent is `#2dd4bf` (brighter)
- Sidebar inactive text is `#64748b` in both modes

- [ ] **Step 3: Commit**

```bash
git add Mend/App/MendApp.swift
git commit -m "feat: set hiddenTitleBar window style and default size"
```

---

## Self-Review

**Spec coverage check:**

| Spec requirement | Covered by |
|-----------------|-----------|
| DesignTokens color system | Task 1 |
| Teal accent light/dark | Task 1 |
| `#64748b` sidebar inactive text | Task 1 (`textNavInactive`) + Task 11 |
| Status dot glow | Task 2 |
| Lucide SVG icons, no emoji | Task 3 |
| Health ring animated | Task 4 |
| `healthScore` computed (ok=100, warn=60, error=0) | Task 5 |
| Hero card: ring + headline + scan button | Task 6 |
| Glass MetricCard with progress bar | Task 7 |
| 3-column grid, 10pt gap | Task 8 |
| ScanRow expand/collapse with chevron rotate | Task 9 |
| ScanView glass list container | Task 10 |
| Full-width 130pt sidebar | Task 11 |
| Active nav item: teal + accent.subtle bg | Task 11 |
| Badge (orange pill) in Updates nav item | Task 11 |
| `.hiddenTitleBar` window style | Task 12 |
| Light + Dark both modes | Tasks 1, 12 |
| `.easeOut(0.4)` ring animation | Task 4 |
| `.easeInOut(0.15)` row expand | Task 9 |
| Warn row tint `rgba(245,158,11,0.025)` | Task 9 |
