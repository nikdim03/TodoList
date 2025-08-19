import Foundation

// Accessibility identifier helpers.
public enum A11yId {
    public static let taskCountLabel = "task_count_label"
    public static let addTaskButton = "add_task_button"
    public static let detailTitleField = "detail_title_field"
    public static let detailCreatedDateLabel = "detail_created_date_label"
    public static let detailDescriptionEditor = "detail_description_editor"
    public static let detailBackButton = "detail_back_button"
    public static let searchField = "search_field"
    public static let todoList = "todo_list"
    public static let loadingIndicator = "loading_indicator"
    public static func taskStatus(_ id: Int64) -> String { "task_status_\(id)" }
    public static func taskTitle(_ id: Int64) -> String { "task_title_\(id)" }
    public static func taskDetail(_ id: Int64) -> String { "task_detail_\(id)" }
    public static func taskCreated(_ id: Int64) -> String {
        "task_created_\(id)"
    }
}
