import Foundation

/// Maps each audited surface to a migration verdict.
///
/// The rules are deliberately small enough to read in one sitting — this is
/// the part of a migration playbook that should be executable, so the team
/// argues about the rules once instead of re-litigating every surface in
/// review.
public enum GlassMigrationClassifier {

    /// Classify a single surface.
    ///
    /// Base verdict comes from the surface kind; `pinsToTabBar` then
    /// escalates to at least `.layoutAudit`, because the floating tab bar's
    /// `safeAreaInsets` change bites regardless of what the surface is made
    /// of. Custom chrome stays `.needsRedesign` — already the most expensive.
    public static func verdict(for component: ChromeComponent) -> MigrationVerdict {
        let base: MigrationVerdict
        switch component.kind {
        case .plainContent:
            base = .unaffected
        case .systemStandard:
            base = .inheritsAutomatically
        case .blurBacked, .materialBacked:
            base = .mechanicalSwap
        case .customChrome:
            base = .needsRedesign
        }

        if component.pinsToTabBar {
            return max(base, .layoutAudit)
        }
        return base
    }

    /// Effort points for one surface: verdict multiplier x usage sites,
    /// with a floor of one site so a redesign of a single-use surface still
    /// costs real points.
    public static func effortPoints(for component: ChromeComponent) -> Int {
        let verdict = verdict(for: component)
        guard verdict.effortMultiplier > 0 else { return 0 }
        return verdict.effortMultiplier * max(1, component.usageSites)
    }
}
