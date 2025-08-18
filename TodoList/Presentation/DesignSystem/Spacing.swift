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
    static let searchBarOuterHorizontal = AppSpacing.lg  // 16 (.padding(.horizontal) after component)
    static let searchBarInnerHorizontal = AppSpacing.md  // 12 inside rounded rect
    static let searchBarInnerVertical = AppSpacing.md - 2  // 10 (kept visually balanced)

    static let gapSearchToList = AppSpacing.lg  // 16 gap below search bar
    static let cellGapVertical = AppSpacing.sm  // 8 gap + divider spacing

    static let detailTitleTop = AppSpacing.xs  // 6 (was 4; adjust if you want exact 4 -> create dedicated token)
    static let detailBottomExtra = AppSpacing.xxxl  // 40

    // Detail notes editor specific metrics
    static let detailNotesPlaceholderHorizontal: CGFloat = 5  // custom value not on 4/6 grid
    static let detailNotesPlaceholderVertical: CGFloat = AppSpacing.sm  // 8
    static let detailNotesMinHeight: CGFloat = 200
    static let detailNotesTightenHorizontal: CGFloat = -4  // negative inset to align text

    static let refreshOverlayTop = AppSpacing.lg / 2  // 8
    static let refreshOverlayPadding = AppSpacing.md / 2  // 6 capsule padding

    // Task row
    static let taskRowInnerSpacing = AppSpacing.sm  // 8 between icon and text
    static let taskRowIconFrame: CGFloat = 32  // width/height for status icon tap area

    // Context menu preview
    static let contextMenuPreviewHorizontal = AppSpacing.lg  // 16 horizontal padding inside preview
    static let contextMenuPreviewVertical: CGFloat = 10  // vertical padding inside preview (custom)

    // Detail screen vertical spacing between sections
    static let detailVerticalStackSpacing = AppSpacing.xl - 4  // 16 (explicit token)

    // Back button icon/text spacing
    static let backButtonInnerSpacing = AppSpacing.xs - 2  // 4

    // Mic button frame (explicit constants not on scale)
    static let micFrameWidth: CGFloat = 17
    static let micFrameHeight: CGFloat = 22

    // Debounce duration (converted to nanoseconds externally)
    static let searchDebounceMillis: UInt64 = 300
}

struct CornerRadiusToken {
    static let searchBar: CGFloat = 14  // Non-scale radius (kept as-is)
}
