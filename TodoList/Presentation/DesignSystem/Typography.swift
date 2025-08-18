import SwiftUI

// MARK: - Typography Tokens
// Central place to manage app font sizing & weight. Adjust here to propagate.
struct AppFont {
    // Display / Large Titles
    static var largeTitle: Font { .system(size: 34, weight: .bold) }

    // List item title
    static var listItemTitle: Font { .system(size: 16, weight: .semibold) }

    // General body / search text
    static var body: Font { .system(size: 17, weight: .regular) }
    static var search: Font { body }

    // Descriptive long text (detail screen description editor)
    static var description: Font { .system(size: 16, weight: .regular) }

    // Metadata (dates)
    static var meta: Font { .system(size: 12, weight: .regular) }

    // Very small metadata (task count)
    static var tinyMeta: Font { .system(size: 11, weight: .regular) }

    // Back button label
    static var backButton: Font { .system(size: 17, weight: .semibold) }
}

// MARK: - Icon Font Tokens
struct IconFont {
    static var status: Font { .system(size: 24, weight: .thin) }  // circle / checkmark
    static var action: Font { .system(size: 22, weight: .regular) }  // add / edit (toolbar)
    static var mic: Font { .system(size: 22, weight: .regular) }  // mic icon
}
