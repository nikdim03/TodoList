import XCTest

@testable import TodoList

final class UseCaseTests: XCTestCase {
    final class RepoMock: TaskRepository, @unchecked Sendable {
        var updated: [TodoItem] = []
        var toggled: [Int64] = []
        func bootstrapIfNeeded(remote: RemoteBootstrapService) async throws {}
        func tasks(matching search: String?) async throws -> [TodoItem] { [] }
        func add(detail: String, title: String?) async throws -> TodoItem {
            .init(id: 1, title: title, detail: detail)
        }
        func update(task: TodoItem) async throws { updated.append(task) }
        func delete(id: Int64) async throws {}
        func toggle(id: Int64) async throws { toggled.append(id) }
    }

    func makeInMemoryStack() -> CoreDataStack { CoreDataStack(inMemory: true) }

    func testAddTaskCreatesItem() async throws {
        let stack = makeInMemoryStack()
        let repo = CoreDataTaskRepository(stack: stack, appConfig: AppConfig())
        let add = AddTask(repo: repo)
        let created = try await add.execute(detail: "Detail", title: "Title")
        XCTAssertEqual(created.title, "Title")
        let get = GetTasks(repo: repo)
        let tasks = try await get.execute(search: nil)
        XCTAssertEqual(tasks.count, 1)
        XCTAssertEqual(tasks.first?.id, created.id)
    }

    func testUpdateTaskDelegatesToRepository() async throws {
        let repo = RepoMock()
        let useCase = UpdateTask(repo: repo)
        let item = TodoItem(id: 123, title: "T", detail: "D")
        try await useCase.execute(task: item)
        XCTAssertEqual(repo.updated.map { $0.id }, [123])
    }

    func testToggleTaskStatusDelegatesToRepository() async throws {
        let repo = RepoMock()
        let useCase = ToggleTaskStatus(repo: repo)
        try await useCase.execute(id: 55)
        XCTAssertEqual(repo.toggled, [55])
    }
}
