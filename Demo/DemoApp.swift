import SwiftUI
import GlassAuditKit

/// Entry point for the GlassAuditKit demo. The whole app is the library's
/// audit dashboard over the bundled sample inventory — clone, open
/// `Demo/Demo.xcodeproj`, pick a Simulator, Build & Run.
@main
struct DemoApp: App {
    var body: some Scene {
        WindowGroup {
            AuditDashboardView()
        }
    }
}
