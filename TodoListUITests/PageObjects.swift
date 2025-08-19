import XCTest

// Local copy of accessibility identifiers to decouple UI test target from app internals linking.
private enum A11yIds {
    static let taskCountLabel = "task_count_label"
    static let addTaskButton = "add_task_button"
    static let detailTitleField = "detail_title_field"
    static let detailDescriptionEditor = "detail_description_editor"
    static let detailBackButton = "detail_back_button"
    static func taskStatus(_ id: Int64) -> String { "task_status_\(id)" }
    static func taskTitle(_ id: Int64) -> String { "task_title_\(id)" }
    static func taskDetail(_ id: Int64) -> String { "task_detail_\(id)" }
    static func taskCreated(_ id: Int64) -> String { "task_created_\(id)" }
}

struct TodoListPage {
    let app: XCUIApplication
    var addButton: XCUIElement { app.buttons[A11yIds.addTaskButton] }
    var taskCountLabel: XCUIElement { app.staticTexts[A11yIds.taskCountLabel] }
    func taskTitle(_ id: Int64) -> XCUIElement {
        app.staticTexts[A11yIds.taskTitle(id)]
    }
    func taskStatus(_ id: Int64) -> XCUIElement {
        app.images[A11yIds.taskStatus(id)]
    }
    var searchField: XCUIElement { app.searchFields.firstMatch }
}

struct TodoDetailPage {
    let app: XCUIApplication
    var titleField: XCUIElement { app.textFields[A11yIds.detailTitleField] }
    var descriptionEditor: XCUIElement {
        app.textViews[A11yIds.detailDescriptionEditor]
    }
    var backButton: XCUIElement { app.buttons[A11yIds.detailBackButton] }
}
