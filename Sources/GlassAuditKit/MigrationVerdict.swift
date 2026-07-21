import Foundation

/// What actually has to happen to a surface before the Xcode 27 recompile
/// ships. Ordered by cost: later cases are strictly more expensive.
public enum MigrationVerdict: Int, CaseIterable, Sendable, Codable, Comparable {
    /// No chrome, no tab-bar-relative layout. Nothing to do.
    case unaffected = 0

    /// Stock system component: Liquid Glass is applied automatically on
    /// recompile. Needs a validation pass, not code changes.
    case inheritsAutomatically = 1

    /// `UIBlurEffect` → `UIGlassEffect`, or SwiftUI material → `glassEffect()`.
    /// Mechanical, per-call-site work — including `GlassEffectContainer` /
    /// `UIGlassContainerEffect` grouping where glass would overlap glass.
    case mechanicalSwap = 2

    /// Layout assumes the old tab bar geometry. The floating tab bar changes
    /// `safeAreaInsets`, so this needs a layout audit and re-test, which is
    /// costlier than a swap because the fix is per-screen, not per-effect.
    case layoutAudit = 3

    /// Hand-drawn chrome with no mechanical equivalent. Needs design +
    /// engineering together; this is the long-pole work.
    case needsRedesign = 4

    public static func < (lhs: MigrationVerdict, rhs: MigrationVerdict) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    /// Effort multiplier applied per usage site. The absolute numbers matter
    /// less than the ratios: a redesign is ~5x a mechanical swap, and a
    /// layout audit is ~2x, because it drags QA back in.
    public var effortMultiplier: Int {
        switch self {
        case .unaffected: return 0
        case .inheritsAutomatically: return 0
        case .mechanicalSwap: return 1
        case .layoutAudit: return 2
        case .needsRedesign: return 5
        }
    }

    /// One-line explanation suitable for a report or dashboard row.
    public var explanation: String {
        switch self {
        case .unaffected:
            return "No chrome and no tab-bar-relative layout. No action."
        case .inheritsAutomatically:
            return "System component. Restyles automatically on the Xcode 27 recompile; validate visually."
        case .mechanicalSwap:
            return "Blur/material chrome. Swap to UIGlassEffect / glassEffect(), grouping adjacent glass in a container."
        case .layoutAudit:
            return "Layout pinned to the old tab bar. Floating tab bar changes safeAreaInsets; audit and re-test."
        case .needsRedesign:
            return "Custom chrome with no mechanical equivalent. Schedule design + engineering redesign."
        }
    }
}
