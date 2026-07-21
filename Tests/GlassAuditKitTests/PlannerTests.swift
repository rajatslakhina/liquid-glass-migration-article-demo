import XCTest
@testable import GlassAuditKit

final class PlannerTests: XCTestCase {

    // MARK: Empty inventory edge cases

    func testEmptyInventoryProducesEmptyPlanAndFullReadiness() {
        let plan = MigrationPlanner.plan(for: [])
        XCTAssertTrue(plan.phases.isEmpty)
        XCTAssertEqual(plan.totalEffort, 0)
        XCTAssertEqual(plan.readinessScore, 100)
        XCTAssertEqual(plan.estimatedWeeks(atPointsPerWeek: 10), 0)
    }

    func testAllFreeInventoryScoresFullReadiness() {
        let inventory = [
            ChromeComponent(name: "Nav", kind: .systemStandard, usageSites: 5),
            ChromeComponent(name: "Content", kind: .plainContent, usageSites: 9)
        ]
        let plan = MigrationPlanner.plan(for: inventory)
        XCTAssertEqual(plan.readinessScore, 100)
        XCTAssertEqual(plan.totalEffort, 0)
    }

    func testAllCustomInventoryScoresZeroReadiness() {
        let inventory = [
            ChromeComponent(name: "Chrome A", kind: .customChrome, usageSites: 2),
            ChromeComponent(name: "Chrome B", kind: .customChrome, usageSites: 1)
        ]
        XCTAssertEqual(MigrationPlanner.plan(for: inventory).readinessScore, 0)
    }

    // MARK: Phase structure

    func testPhasesAppearInFixedOrderAndSkipEmptyOnes() {
        let inventory = [
            ChromeComponent(name: "Blur", kind: .blurBacked),
            ChromeComponent(name: "Custom", kind: .customChrome)
        ]
        let plan = MigrationPlanner.plan(for: inventory)
        XCTAssertEqual(plan.phases.map(\.verdict), [.mechanicalSwap, .needsRedesign])
    }

    func testSampleInventoryPhaseOrderIsMonotonicInVerdict() {
        let plan = MigrationPlanner.plan(for: SampleInventory.dualStackApp)
        let verdicts = plan.phases.map(\.verdict)
        XCTAssertEqual(verdicts, verdicts.sorted())
        XCTAssertFalse(plan.phases.isEmpty)
    }

    func testCriticalPathSortsFirstWithinPhase() {
        let inventory = [
            ChromeComponent(name: "Big but not critical", kind: .blurBacked, usageSites: 10),
            ChromeComponent(name: "Small but critical", kind: .blurBacked, usageSites: 1, isCriticalPath: true)
        ]
        let plan = MigrationPlanner.plan(for: inventory)
        let swapPhase = plan.phases.first { $0.verdict == .mechanicalSwap }
        XCTAssertEqual(swapPhase?.components.first?.name, "Small but critical")
    }

    func testHigherEffortSortsFirstAmongEqualCriticality() {
        let inventory = [
            ChromeComponent(name: "Two sites", kind: .materialBacked, usageSites: 2),
            ChromeComponent(name: "Six sites", kind: .materialBacked, usageSites: 6)
        ]
        let plan = MigrationPlanner.plan(for: inventory)
        let swapPhase = plan.phases.first { $0.verdict == .mechanicalSwap }
        XCTAssertEqual(swapPhase?.components.first?.name, "Six sites")
    }

    func testPhaseEffortTotalsMatchComponentSum() {
        let plan = MigrationPlanner.plan(for: SampleInventory.dualStackApp)
        for phase in plan.phases {
            let expected = phase.components.reduce(0) { $0 + GlassMigrationClassifier.effortPoints(for: $1) }
            XCTAssertEqual(phase.totalEffort, expected)
        }
        XCTAssertEqual(plan.totalEffort, plan.phases.reduce(0) { $0 + $1.totalEffort })
    }

    // MARK: Readiness bounds

    func testReadinessStaysWithinBounds() {
        let plan = MigrationPlanner.plan(for: SampleInventory.dualStackApp)
        XCTAssertGreaterThanOrEqual(plan.readinessScore, 0)
        XCTAssertLessThanOrEqual(plan.readinessScore, 100)
        // Mixed inventory: strictly between the extremes.
        XCTAssertGreaterThan(plan.readinessScore, 0)
        XCTAssertLessThan(plan.readinessScore, 100)
    }

    // MARK: Runway estimate

    func testRunwayRoundsUp() {
        let inventory = [ChromeComponent(name: "Blur", kind: .blurBacked, usageSites: 11)]
        let plan = MigrationPlanner.plan(for: inventory)
        XCTAssertEqual(plan.totalEffort, 11)
        XCTAssertEqual(plan.estimatedWeeks(atPointsPerWeek: 10), 2)
    }

    func testRunwayRejectsNonPositiveCapacity() {
        let plan = MigrationPlanner.plan(for: SampleInventory.dualStackApp)
        XCTAssertNil(plan.estimatedWeeks(atPointsPerWeek: 0))
        XCTAssertNil(plan.estimatedWeeks(atPointsPerWeek: -3))
    }
}
