import XCTest
@testable import GlassAuditKit

final class ClassifierTests: XCTestCase {

    private func component(
        kind: SurfaceKind,
        usageSites: Int = 1,
        critical: Bool = false,
        pins: Bool = false
    ) -> ChromeComponent {
        ChromeComponent(
            name: "Test",
            kind: kind,
            usageSites: usageSites,
            isCriticalPath: critical,
            pinsToTabBar: pins
        )
    }

    // MARK: Base verdicts per kind

    func testPlainContentIsUnaffected() {
        XCTAssertEqual(GlassMigrationClassifier.verdict(for: component(kind: .plainContent)), .unaffected)
    }

    func testSystemStandardInheritsAutomatically() {
        XCTAssertEqual(GlassMigrationClassifier.verdict(for: component(kind: .systemStandard)), .inheritsAutomatically)
    }

    func testBlurBackedIsMechanicalSwap() {
        XCTAssertEqual(GlassMigrationClassifier.verdict(for: component(kind: .blurBacked)), .mechanicalSwap)
    }

    func testMaterialBackedIsMechanicalSwap() {
        XCTAssertEqual(GlassMigrationClassifier.verdict(for: component(kind: .materialBacked)), .mechanicalSwap)
    }

    func testCustomChromeNeedsRedesign() {
        XCTAssertEqual(GlassMigrationClassifier.verdict(for: component(kind: .customChrome)), .needsRedesign)
    }

    // MARK: Tab-bar pinning escalation

    func testPinnedPlainContentEscalatesToLayoutAudit() {
        XCTAssertEqual(
            GlassMigrationClassifier.verdict(for: component(kind: .plainContent, pins: true)),
            .layoutAudit
        )
    }

    func testPinnedSystemStandardEscalatesToLayoutAudit() {
        XCTAssertEqual(
            GlassMigrationClassifier.verdict(for: component(kind: .systemStandard, pins: true)),
            .layoutAudit
        )
    }

    func testPinnedBlurBackedEscalatesToLayoutAudit() {
        XCTAssertEqual(
            GlassMigrationClassifier.verdict(for: component(kind: .blurBacked, pins: true)),
            .layoutAudit
        )
    }

    func testPinnedCustomChromeStaysNeedsRedesign() {
        // Redesign already outranks a layout audit; pinning must not demote it.
        XCTAssertEqual(
            GlassMigrationClassifier.verdict(for: component(kind: .customChrome, pins: true)),
            .needsRedesign
        )
    }

    // MARK: Effort model

    func testEffortScalesWithUsageSites() {
        XCTAssertEqual(GlassMigrationClassifier.effortPoints(for: component(kind: .blurBacked, usageSites: 3)), 3)
        XCTAssertEqual(GlassMigrationClassifier.effortPoints(for: component(kind: .customChrome, usageSites: 2)), 10)
    }

    func testZeroUsageSitesStillCostsOneSiteOfEffort() {
        // Edge case: a surface found by audit but with a miscounted zero
        // usage still needs the work done once.
        XCTAssertEqual(GlassMigrationClassifier.effortPoints(for: component(kind: .customChrome, usageSites: 0)), 5)
    }

    func testFreeVerdictsCostNothing() {
        XCTAssertEqual(GlassMigrationClassifier.effortPoints(for: component(kind: .plainContent, usageSites: 40)), 0)
        XCTAssertEqual(GlassMigrationClassifier.effortPoints(for: component(kind: .systemStandard, usageSites: 12)), 0)
    }

    func testNegativeUsageSitesClampedAtInit() {
        let negative = ChromeComponent(name: "Bad ingest", kind: .blurBacked, usageSites: -5)
        XCTAssertEqual(negative.usageSites, 0)
        XCTAssertEqual(GlassMigrationClassifier.effortPoints(for: negative), 1)
    }

    func testVerdictSeverityOrderingIsMonotonic() {
        let ordered: [MigrationVerdict] = [.unaffected, .inheritsAutomatically, .mechanicalSwap, .layoutAudit, .needsRedesign]
        XCTAssertEqual(ordered, MigrationVerdict.allCases.sorted())
    }
}
