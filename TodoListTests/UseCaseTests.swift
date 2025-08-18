import XCTest

@testable import TodoList

final class UseCaseTests: XCTestCase {
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
}
