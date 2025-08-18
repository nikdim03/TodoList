import Foundation

public struct TodoItem: Identifiable, Equatable, Sendable {
    public enum Status: String, Codable, Sendable { case pending, completed }
    public let id: Int64
    public var title: String
    public var detail: String
    public let createdAt: Date
    public var status: Status

    public init(
        id: Int64,
        title: String?,
        detail: String,
        createdAt: Date = Date(),
        status: Status = .pending
    ) {
        self.id = id
        if let title = title?.trimmingCharacters(in: .whitespacesAndNewlines),
            !title.isEmpty {
            self.title = title
        } else {
            self.title = "Task #\(id)"
        }
        self.detail = detail
        self.createdAt = createdAt
        self.status = status
    }
}
