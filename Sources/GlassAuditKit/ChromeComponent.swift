import Foundation

/// The kind of "chrome" a UI surface is built from, seen through the only lens
/// that matters for a Liquid Glass migration: what happens to it when the app
/// is recompiled with Xcode 27 and `UIDesignRequiresCompatibility` is ignored.
public enum SurfaceKind: String, CaseIterable, Sendable, Codable {
    /// Stock UIKit/SwiftUI system components (navigation bars, tab bars,
    /// toolbars) with no appearance overrides. The system restyles these.
    case systemStandard

    /// UIKit surfaces backed by `UIBlurEffect` inside a `UIVisualEffectView`.
    /// These are the mechanical `UIGlassEffect` swap candidates.
    case blurBacked

    /// SwiftUI surfaces using `.ultraThinMaterial` / `.regularMaterial` etc.
    /// The `glassEffect()` swap candidates on the SwiftUI side.
    case materialBacked

    /// Hand-drawn chrome: custom nav/tab bar backgrounds, gradient overlays,
    /// bespoke floating panels. No mechanical path — needs design review.
    case customChrome

    /// Plain content views that render no chrome of their own.
    case plainContent
}

/// One audited UI surface in the app's chrome inventory.
///
/// `pinsToTabBar` is tracked separately from `kind` because the iOS 27
/// floating tab bar changes `safeAreaInsets`: any layout that pins content
/// relative to the old tab bar frame is a migration item even if the view
/// itself renders no chrome at all.
public struct ChromeComponent: Identifiable, Hashable, Sendable, Codable {
    public let id: UUID
    public let name: String
    public let kind: SurfaceKind

    /// How many call sites / screens use this surface. Clamped to zero so a
    /// bad ingest (e.g. a miscounted grep) can never produce negative effort.
    public let usageSites: Int

    /// Surfaces on the critical path (checkout, playback, capture) are
    /// migrated first within their phase.
    public let isCriticalPath: Bool

    /// True when layout code positions this surface relative to the tab bar.
    public let pinsToTabBar: Bool

    public init(
        id: UUID = UUID(),
        name: String,
        kind: SurfaceKind,
        usageSites: Int = 1,
        isCriticalPath: Bool = false,
        pinsToTabBar: Bool = false
    ) {
        self.id = id
        self.name = name
        self.kind = kind
        self.usageSites = max(0, usageSites)
        self.isCriticalPath = isCriticalPath
        self.pinsToTabBar = pinsToTabBar
    }
}
