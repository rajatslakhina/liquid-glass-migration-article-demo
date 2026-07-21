import Foundation

/// Renders a migration plan as a plain-text report — the artifact you paste
/// into the planning doc or print from CI so the audit output is reviewable
/// like any other build product.
public enum AuditReport {

    public static func render(for inventory: [ChromeComponent]) -> String {
        let plan = MigrationPlanner.plan(for: inventory)
        var lines: [String] = []

        lines.append("LIQUID GLASS MIGRATION AUDIT")
        lines.append("Surfaces audited: \(inventory.count)")
        lines.append("Readiness score: \(plan.readinessScore)/100")
        lines.append("Total effort: \(plan.totalEffort) points")

        if inventory.isEmpty {
            lines.append("Inventory is empty — nothing to migrate.")
            return lines.joined(separator: "\n")
        }

        if let weeks = plan.estimatedWeeks(atPointsPerWeek: 10) {
            lines.append("Runway at 10 pts/week: \(weeks) week(s)")
        }

        for phase in plan.phases {
            lines.append("")
            lines.append("PHASE \(phase.id + 1): \(phase.title) — \(phase.totalEffort) pts")
            for component in phase.components {
                let critical = component.isCriticalPath ? " [CRITICAL]" : ""
                let effort = GlassMigrationClassifier.effortPoints(for: component)
                lines.append("  - \(component.name)\(critical) (\(component.usageSites) sites, \(effort) pts)")
            }
        }

        return lines.joined(separator: "\n")
    }
}
