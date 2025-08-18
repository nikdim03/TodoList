import XCTest

@testable import TodoList

final class RepositoryTests: XCTestCase {
    func testAddAndFetch() async throws {
        let stack = CoreDataStack(inMemory: true)
        let repo = CoreDataTaskRepository(stack: stack, appConfig: AppConfig())
        _ = try await repo.add(detail: "Detail", title: "Hello")
        let tasks = try await repo.tasks(matching: nil)
        XCTAssertEqual(tasks.count, 1)
        XCTAssertEqual(tasks.first?.title, "Hello")
    }
}
