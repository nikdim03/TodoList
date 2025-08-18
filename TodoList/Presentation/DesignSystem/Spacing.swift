import SwiftUI

// MARK: - Spacing & Layout Tokens
// Centralized layout metrics to eliminate magic numbers in paddings & spacers.
struct AppSpacing {
    // Base scale (you can adjust the base numbers later if design shifts)
    static let xxs: CGFloat = 4 // swiftlint:disable:this identifier_name
    static let xs: CGFloat = 6 // swiftlint:disable:this identifier_name
    static let sm: CGFloat = 8 // swiftlint:disable:this identifier_name
    static let md: CGFloat = 12 // swiftlint:disable:this identifier_name
    static let lg: CGFloat = 16 // swiftlint:disable:this identifier_name
    static let xl: CGFloat = 20 // swiftlint:disable:this identifier_name
    static let xxl: CGFloat = 24 // swiftlint:disable:this identifier_name
    static let xxxl: CGFloat = 40 // swiftlint:disable:this identifier_name
}

struct LayoutPadding {
    // Horizontal content padding for main screens
    static let screenHorizontal = AppSpacing.xl  // 20
    static let listRowHorizontal = AppSpacing.xl  // 20

    static let cellGapVertical = AppSpacing.sm  // 8 gap + divider spacing

    // Detail notes editor specific metrics
    static let detailNotesPlaceholderHorizontal: CGFloat = 5  // custom value not on 4/6 grid
    static let detailNotesPlaceholderVertical: CGFloat = AppSpacing.sm  // 8
    static let detailNotesMinHeight: CGFloat = 200

    // Task row
    static let taskRowInnerSpacing = AppSpacing.sm  // 8 between icon and text
    static let taskRowIconFrame: CGFloat = 32  // width/height for status icon tap area
}
