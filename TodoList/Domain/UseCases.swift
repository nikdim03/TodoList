import Foundation

// MARK: - Protocols
public protocol LoadInitialTasksIfNeededUseCase { func execute() async throws }
public protocol GetTasksUseCase {
    func execute(search: String?) async throws -> [TodoItem]
}
public protocol AddTaskUseCase {
    func execute(detail: String, title: String?) async throws -> TodoItem
}
public protocol UpdateTaskUseCase { func execute(task: TodoItem) async throws }
public protocol DeleteTaskUseCase { func execute(id: Int64) async throws }
public protocol ToggleTaskStatusUseCase { func execute(id: Int64) async throws }

public enum TaskError: Error, Equatable {
    case notFound, network, decode, persistence
    case validation(String)
}

// MARK: - Repository Abstraction
public protocol TaskRepository: AnyObject, Sendable {
    func bootstrapIfNeeded(remote: RemoteBootstrapService) async throws
    func tasks(matching search: String?) async throws -> [TodoItem]
    func add(detail: String, title: String?) async throws -> TodoItem
    func update(task: TodoItem) async throws
    func delete(id: Int64) async throws
    func toggle(id: Int64) async throws
}

public protocol RemoteBootstrapService: AnyObject, Sendable {
    func fetchTodos() async throws -> [RemoteTodoDTO]
}

public struct RemoteTodoDTO: Codable, Sendable {
    public let id: Int
    public let todo: String
    public let completed: Bool
    public let userId: Int
}

// MARK: - Concrete Use Case Implementations
public final class LoadInitialTasksIfNeeded: LoadInitialTasksIfNeededUseCase {
    private let repo: TaskRepository
    private let remote: RemoteBootstrapService
    public init(repo: TaskRepository, remote: RemoteBootstrapService) {
        self.repo = repo
        self.remote = remote
    }
    public func execute() async throws {
        try await repo.bootstrapIfNeeded(remote: remote)
    }
}
public final class GetTasks: GetTasksUseCase {
    private let repo: TaskRepository
    public init(repo: TaskRepository) { self.repo = repo }
    public func execute(search: String?) async throws -> [TodoItem] {
        try await repo.tasks(matching: search)
    }
}
public final class AddTask: AddTaskUseCase {
    private let repo: TaskRepository
    public init(repo: TaskRepository) { self.repo = repo }
    public func execute(detail: String, title: String?) async throws -> TodoItem {
        try await repo.add(detail: detail, title: title)
    }
}
public final class UpdateTask: UpdateTaskUseCase {
    private let repo: TaskRepository
    public init(repo: TaskRepository) { self.repo = repo }
    public func execute(task: TodoItem) async throws {
        try await repo.update(task: task)
    }
}
public final class DeleteTask: DeleteTaskUseCase {
    private let repo: TaskRepository
    public init(repo: TaskRepository) { self.repo = repo }
    public func execute(id: Int64) async throws {
        try await repo.delete(id: id)
    }
}
public final class ToggleTaskStatus: ToggleTaskStatusUseCase {
    private let repo: TaskRepository
    public init(repo: TaskRepository) { self.repo = repo }
    public func execute(id: Int64) async throws {
        try await repo.toggle(id: id)
    }
}
