#if canImport(SwiftUI)
import SwiftUI

/// The audit rendered as a screen: readiness up top, then the phased plan in
/// working order. This is the view the Demo app shows as its root scene.
public struct AuditDashboardView: View {
    private let inventory: [ChromeComponent]
    private let plan: MigrationPlan

    public init(inventory: [ChromeComponent] = SampleInventory.dualStackApp) {
        self.inventory = inventory
        self.plan = MigrationPlanner.plan(for: inventory)
    }

    public var body: some View {
        NavigationStack {
            List {
                Section {
                    readinessHeader
                }

                ForEach(plan.phases) { phase in
                    Section("Phase \(phase.id + 1) · \(phase.totalEffort) pts") {
                        Text(phase.title)
                            .font(.subheadline.weight(.semibold))
                        ForEach(phase.components) { component in
                            componentRow(component)
                        }
                    }
                }
            }
            .navigationTitle("Glass Audit")
        }
    }

    private var readinessHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Readiness")
                    .font(.headline)
                Spacer()
                Text("\(plan.readinessScore)/100")
                    .font(.title2.weight(.bold).monospacedDigit())
            }
            ProgressView(value: Double(plan.readinessScore), total: 100)
            HStack {
                Label("\(inventory.count) surfaces", systemImage: "square.stack.3d.up")
                Spacer()
                Label("\(plan.totalEffort) pts remaining", systemImage: "hammer")
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            if let weeks = plan.estimatedWeeks(atPointsPerWeek: 10) {
                Text("≈ \(weeks) week(s) at 10 pts/week — deadline: Xcode 27 App Store baseline (~April 2027)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private func componentRow(_ component: ChromeComponent) -> some View {
        let verdict = GlassMigrationClassifier.verdict(for: component)
        let effort = GlassMigrationClassifier.effortPoints(for: component)
        return VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                if component.isCriticalPath {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundStyle(.orange)
                        .accessibilityLabel("Critical path")
                }
                Text(component.name)
                    .font(.subheadline)
                Spacer()
                Text("\(effort) pts")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            Text(verdict.explanation)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    AuditDashboardView()
}
#endif
