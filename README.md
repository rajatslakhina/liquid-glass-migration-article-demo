# GlassAuditKit — a Liquid Glass migration audit, as executable code

Xcode 27 ignores `UIDesignRequiresCompatibility`. Once Xcode 27 becomes the App Store
submission baseline (~April 2027), every app gets Liquid Glass — ready or not.

This repo is the companion demo for the article **"Your Liquid Glass Opt-Out Just
Expired. Here's the Audit I'd Run This Week"** *(link added after publish — see below)*.
Instead of describing a migration playbook in prose, it encodes one:

- **`ChromeComponent`** — one audited UI surface: what it's made of (`systemStandard`,
  `blurBacked`, `materialBacked`, `customChrome`, `plainContent`), how many call sites
  use it, whether it's on the critical path, and whether its layout pins to the tab bar.
- **`GlassMigrationClassifier`** — maps each surface to a verdict: `inheritsAutomatically`,
  `mechanicalSwap` (UIBlurEffect → UIGlassEffect / material → `glassEffect()`),
  `layoutAudit` (the floating tab bar changes `safeAreaInsets`), `needsRedesign`, or
  `unaffected`. Tab-bar pinning escalates any verdict to at least a layout audit.
- **`MigrationPlanner`** — turns the inventory into a phased plan with effort points,
  a usage-weighted 0–100 readiness score, and a capacity-based runway estimate.
- **`AuditReport`** — renders the plan as plain text, so the audit is a build artifact
  you can diff in CI, not a slide.
- **`AuditDashboardView`** — the same plan as a SwiftUI screen (the Demo app's root view).

## The classifier in one glance

```swift
public static func verdict(for component: ChromeComponent) -> MigrationVerdict {
    let base: MigrationVerdict
    switch component.kind {
    case .plainContent:                 base = .unaffected
    case .systemStandard:               base = .inheritsAutomatically
    case .blurBacked, .materialBacked:  base = .mechanicalSwap
    case .customChrome:                 base = .needsRedesign
    }
    if component.pinsToTabBar {
        return max(base, .layoutAudit)   // floating tab bar changes safeAreaInsets
    }
    return base
}
```

## How to run it

1. Clone this repo.
2. Open `Demo/Demo.xcodeproj` in Xcode.
3. Pick any iOS Simulator and **Build & Run**. No other setup — the app consumes the
   library through a local Swift Package reference in the same repo.

To run the tests headlessly: `swift test` at the repo root.

## Verification status (honest)

- `swift build` and `swift test` were run on Linux with a Swift 6.0.3 toolchain:
  **28/28 tests pass** (classifier rules, tab-bar escalation, planner phase ordering,
  critical-first sorting, readiness bounds, runway divide-by-zero guard, report output).
- The SwiftUI layer (`AuditDashboardView`, `DemoApp`) compiles out on Linux via
  `#if canImport(SwiftUI)`, so it was verified by manual review plus scripted checks
  (zero force-unwraps, balanced `project.pbxproj`, schema-validated `.xcscheme`) —
  not by a live Xcode build.
- **No Simulator run or screenshots this time**: this repo was produced by an
  unattended scheduled run, and the environment hard-blocks GUI/Simulator access
  during scheduled runs (the access request was made and refused). Rather than fake a
  screenshot, this README ships without one until a supervised session can add it.

## Screenshots

*Pending — to be added from a supervised Xcode session (see verification note above).*

## Article

Article: *(added after publish — see below)*

## License

MIT
