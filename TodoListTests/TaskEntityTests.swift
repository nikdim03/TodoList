import XCTest

@testable import TodoList

final class TaskEntityTests: XCTestCase {
    func testTitleGenerationWhenNil() {
        let t = TodoItem(id: 42, title: nil, detail: "abc")
        XCTAssertEqual(t.title, "Task #42")
    }
    func testTitleGenerationWhenEmpty() {
        let t = TodoItem(id: 5, title: "   ", detail: "abc")
        XCTAssertEqual(t.title, "Task #5")
    }
    func testKeepsProvidedTitle() {
        let t = TodoItem(id: 1, title: "Hello", detail: "abc")
        XCTAssertEqual(t.title, "Hello")
    }
}
