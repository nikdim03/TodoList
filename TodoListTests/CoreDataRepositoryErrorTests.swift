import CoreData
import XCTest

@testable import TodoList

final class CoreDataRepositoryErrorTests: XCTestCase {
    func testUpdateNotFoundThrowsNotFound() async throws {
        let stack = CoreDataStack(inMemory: true)
        let repo = CoreDataTaskRepository(stack: stack, appConfig: AppConfig())
        let missing = TodoItem(id: 999, title: "X", detail: "")
        do {
            try await repo.update(task: missing)
            XCTFail("Expected notFound error")
        } catch let err as TaskError {
            XCTAssertEqual(err, .notFound)
        } catch { XCTFail("Unexpected error: \(error)") }
    }

    func testToggleNotFoundThrowsNotFound() async throws {
        let stack = CoreDataStack(inMemory: true)
        let repo = CoreDataTaskRepository(stack: stack, appConfig: AppConfig())
        do {
            try await repo.toggle(id: 12345)
            XCTFail("Expected notFound")
        } catch let err as TaskError { XCTAssertEqual(err, .notFound) } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
