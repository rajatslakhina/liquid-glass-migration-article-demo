import Foundation

/// A realistic inventory for a mid-size dual-stack (UIKit + SwiftUI) app —
/// the kind of shape you find when you actually run the audit: mostly free,
/// a fistful of mechanical swaps, and two or three surfaces that dominate
/// the whole migration.
public enum SampleInventory {

    public static let dualStackApp: [ChromeComponent] = [
        ChromeComponent(
            name: "System navigation bars (stock appearance)",
            kind: .systemStandard,
            usageSites: 14
        ),
        ChromeComponent(
            name: "System tab bar",
            kind: .systemStandard,
            usageSites: 1
        ),
        ChromeComponent(
            name: "Settings & detail screens (plain content)",
            kind: .plainContent,
            usageSites: 22
        ),
        ChromeComponent(
            name: "Now Playing bar (UIVisualEffectView + UIBlurEffect)",
            kind: .blurBacked,
            usageSites: 3,
            isCriticalPath: true,
            pinsToTabBar: true
        ),
        ChromeComponent(
            name: "Search overlay (.ultraThinMaterial)",
            kind: .materialBacked,
            usageSites: 2
        ),
        ChromeComponent(
            name: "Paywall banner (UIBlurEffect)",
            kind: .blurBacked,
            usageSites: 1,
            isCriticalPath: true
        ),
        ChromeComponent(
            name: "Promo card sheet (.regularMaterial)",
            kind: .materialBacked,
            usageSites: 4
        ),
        ChromeComponent(
            name: "Custom gradient tab bar background",
            kind: .customChrome,
            usageSites: 1,
            isCriticalPath: true,
            pinsToTabBar: true
        ),
        ChromeComponent(
            name: "Hand-drawn onboarding chrome",
            kind: .customChrome,
            usageSites: 2
        ),
        ChromeComponent(
            name: "Mini-player pinned above tab bar (plain view)",
            kind: .plainContent,
            usageSites: 1,
            pinsToTabBar: true
        )
    ]
}
