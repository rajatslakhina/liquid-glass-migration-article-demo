import Foundation

/// One stage of the migration, holding the surfaces it covers and the effort
/// they represent. Within a phase, critical-path surfaces sort first, then by
/// descending effort, so the plan reads in the order you would actually work.
public struct MigrationPhase: Identifiable, Sendable {
    public let id: Int
    public let title: String
    public let verdict: MigrationVerdict
    public let components: [ChromeComponent]
    public let totalEffort: Int
}

/// The full phased plan plus the two numbers a lead actually reports upward:
/// a readiness score and a capacity-based runway estimate.
public struct MigrationPlan: Sendable {
    public let phases: [MigrationPhase]
    public let totalEffort: Int

    /// 0–100. Usage-weighted share of the inventory that needs no code
    /// changes (`unaffected` + `inheritsAutomatically`). An empty inventory
    /// scores 100 — there is nothing to migrate.
    public let readinessScore: Int

    /// Weeks of work at the given capacity, rounded up. Returns nil for a
    /// non-positive capacity instead of dividing by zero.
    public func estimatedWeeks(atPointsPerWeek capacity: Int) -> Int? {
        guard capacity > 0 else { return nil }
        guard totalEffort > 0 else { return 0 }
        return (totalEffort + capacity - 1) / capacity
    }
}

/// Builds a `MigrationPlan` from an audited inventory.
public enum MigrationPlanner {

    /// Phase order is fixed and intentional: validate what you get for free,
    /// burn down the mechanical swaps, then the layout audits, and start the
    /// redesigns last-phase-first in calendar terms because they have the
    /// longest lead time.
    static let phaseOrder: [(verdict: MigrationVerdict, title: String)] = [
        (.inheritsAutomatically, "Recompile & validate inherited surfaces"),
        (.mechanicalSwap, "Mechanical swaps: UIBlurEffect → UIGlassEffect, material → glassEffect()"),
        (.layoutAudit, "Layout audits: floating tab bar & safeAreaInsets"),
        (.needsRedesign, "Custom chrome redesign")
    ]

    public static func plan(for inventory: [ChromeComponent]) -> MigrationPlan {
        var phases: [MigrationPhase] = []
        var totalEffort = 0

        for (index, entry) in phaseOrder.enumerated() {
            let members = inventory
                .filter { GlassMigrationClassifier.verdict(for: $0) == entry.verdict }
                .sorted { lhs, rhs in
                    if lhs.isCriticalPath != rhs.isCriticalPath {
                        return lhs.isCriticalPath
                    }
                    let lhsEffort = GlassMigrationClassifier.effortPoints(for: lhs)
                    let rhsEffort = GlassMigrationClassifier.effortPoints(for: rhs)
                    if lhsEffort != rhsEffort {
                        return lhsEffort > rhsEffort
                    }
                    return lhs.name < rhs.name
                }

            guard !members.isEmpty else { continue }

            let effort = members.reduce(0) { $0 + GlassMigrationClassifier.effortPoints(for: $1) }
            totalEffort += effort
            phases.append(
                MigrationPhase(
                    id: index,
                    title: entry.title,
                    verdict: entry.verdict,
                    components: members,
                    totalEffort: effort
                )
            )
        }

        return MigrationPlan(
            phases: phases,
            totalEffort: totalEffort,
            readinessScore: readinessScore(for: inventory)
        )
    }

    /// Usage-weighted readiness. Every component weighs at least one site so
    /// zero-usage rows cannot silently vanish from the denominator.
    static func readinessScore(for inventory: [ChromeComponent]) -> Int {
        guard !inventory.isEmpty else { return 100 }

        var freeWeight = 0
        var totalWeight = 0
        for component in inventory {
            let weight = max(1, component.usageSites)
            totalWeight += weight
            if GlassMigrationClassifier.verdict(for: component) <= .inheritsAutomatically {
                freeWeight += weight
            }
        }

        guard totalWeight > 0 else { return 100 }
        return (freeWeight * 100) / totalWeight
    }
}
