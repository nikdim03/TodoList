import XCTest

@testable import TodoList

final class StringsPluralizationTests: XCTestCase {
    func testRussianPluralizationEdgeCases() {
        XCTAssertEqual(Strings.taskCountLabel(1), "1 Задача")
        XCTAssertEqual(Strings.taskCountLabel(2), "2 Задачи")
        XCTAssertEqual(Strings.taskCountLabel(4), "4 Задачи")
        XCTAssertEqual(Strings.taskCountLabel(5), "5 Задач")
        XCTAssertEqual(Strings.taskCountLabel(11), "11 Задач")
        XCTAssertEqual(Strings.taskCountLabel(14), "14 Задач")
        XCTAssertEqual(Strings.taskCountLabel(21), "21 Задача")
        XCTAssertEqual(Strings.taskCountLabel(112), "112 Задач")
    }
}
