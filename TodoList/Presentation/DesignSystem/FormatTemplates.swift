import Foundation

// Reusable string templates & non-localized format helpers shared across layers.
public enum FormatTemplates {
    public static func russianTaskTitle(id: Int64) -> String { "Задача #\(id)" }
    public static func englishTaskTitle(id: Int64) -> String { "Task #\(id)" }
    public static let coreDataUnresolvedError = "Unresolved Core Data error: %@"
    public static let predicateTitleOrDetail = "(title CONTAINS[cd] %@) OR (detail CONTAINS[cd] %@)"
    public static let bootstrapFlagKey = "didBootstrap"
    public static let persistentStoreName = "TodoList"
    public static let remoteTodosURLString = "https://dummyjson.com/todos"
    public static let logPrefix = "[LOG]"
    public static let errorPrefix = "[ERROR]"
    public static let fetchTasksFailed = "Fetch tasks failed: %@"
    public static let predicateIdEquals = "id == %d"
    public static let devNullPath = "/dev/null"
    public static let httpStatusOK = 200
}

public enum CoreDataKeys {
    public static let createdAt = "createdAt"
}
