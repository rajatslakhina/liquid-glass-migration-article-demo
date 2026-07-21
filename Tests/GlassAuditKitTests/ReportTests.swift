import XCTest
@testable import GlassAuditKit

final class ReportTests: XCTestCase {

    func testReportForEmptyInventoryStatesNothingToMigrate() {
        let report = AuditReport.render(for: [])
        XCTAssertTrue(report.contains("Readiness score: 100/100"))
        XCTAssertTrue(report.contains("nothing to migrate"))
        XCTAssertFalse(report.contains("PHASE"))
    }

    func testReportListsEveryNonFreeSurfaceAndPhaseTitles() {
        let report = AuditReport.render(for: SampleInventory.dualStackApp)
        XCTAssertTrue(report.contains("PHASE"))
        XCTAssertTrue(report.contains("Mechanical swaps"))
        XCTAssertTrue(report.contains("Custom chrome redesign"))
        XCTAssertTrue(report.contains("Now Playing bar"))
        XCTAssertTrue(report.contains("[CRITICAL]"))
    }

    func testReportIsDeterministic() {
        let first = AuditReport.render(for: SampleInventory.dualStackApp)
        let second = AuditReport.render(for: SampleInventory.dualStackApp)
        XCTAssertEqual(first, second)
    }
}
