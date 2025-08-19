import XCTest

@testable import TodoList

final class BootstrapRepositoryTests: XCTestCase {
    final class RemoteMock: RemoteBootstrapService, @unchecked Sendable {
        var fetchCalled = false
        var toReturn: [RemoteTodoDTO] = []

        func fetchTodos() async throws -> [RemoteTodoDTO] {
            fetchCalled = true
            return toReturn
        }
    }

    func testBootstrapPersistsRemoteDataOnce() async throws {
        let stack = CoreDataStack(inMemory: true)
        let appConfig = AppConfig()
        appConfig.didBootstrap = false
        let repo = CoreDataTaskRepository(stack: stack, appConfig: appConfig)
        let remote = RemoteMock()
        remote.toReturn = [
            RemoteTodoDTO(id: 1, todo: "Do it", completed: false, userId: 1)
        ]
        try await repo.bootstrapIfNeeded(remote: remote)
        XCTAssertTrue(remote.fetchCalled)
        let tasks = try await repo.tasks(matching: nil)
        XCTAssertEqual(tasks.count, 1)
        // Second call should be a no-op (flag set)
        remote.fetchCalled = false
        try await repo.bootstrapIfNeeded(remote: remote)
        XCTAssertFalse(remote.fetchCalled)
    }

    func testToggleAndDeleteBehavior() async throws {
        let stack = CoreDataStack(inMemory: true)
        let repo = CoreDataTaskRepository(stack: stack, appConfig: AppConfig())
        let created = try await repo.add(detail: "D", title: "T")
        try await repo.toggle(id: created.id)
        var tasks = try await repo.tasks(matching: nil)
        XCTAssertEqual(tasks.first?.status, .completed)
        try await repo.delete(id: created.id)
        tasks = try await repo.tasks(matching: nil)
        XCTAssertTrue(tasks.isEmpty)
    }
}
