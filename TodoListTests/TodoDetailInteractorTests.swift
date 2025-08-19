import XCTest

@testable import TodoList

final class TodoDetailInteractorTests: XCTestCase {
    final class AddMock: AddTaskUseCase {
        var added: [(String, String?)] = []
        func execute(detail: String, title: String?) async throws -> TodoItem {
            added.append((detail, title))
            return TodoItem(id: 99, title: title, detail: detail)
        }
    }
    final class UpdateMock: UpdateTaskUseCase {
        var updated: [TodoItem] = []
        func execute(task: TodoItem) async throws { updated.append(task) }
    }

    func testPersistCreatesWhenNewAndNonEmpty() async {
        let add = AddMock()
        let update = UpdateMock()
        let interactor = TodoDetailInteractor(
            original: nil,
            add: add,
            update: update,
            output: nil
        )
        await interactor.persistIfNeeded(
            current: nil,
            draft: TodoDetailDraft(
                title: "Title ",
                detail: "Detail",
                isCompleted: false
            )
        )
        XCTAssertEqual(add.added.count, 1)
        XCTAssertEqual(update.updated.count, 0)
    }

    func testPersistSkipsCreationWhenEmpty() async {
        let add = AddMock()
        let update = UpdateMock()
        let interactor = TodoDetailInteractor(
            original: nil,
            add: add,
            update: update,
            output: nil
        )
        await interactor.persistIfNeeded(
            current: nil,
            draft: TodoDetailDraft(
                title: "  ",
                detail: "   ",
                isCompleted: false
            )
        )
        XCTAssertEqual(add.added.count, 0)
    }

    func testPersistUpdatesWhenChanged() async {
        let add = AddMock()
        let update = UpdateMock()
        let original = TodoItem(id: 1, title: "Old", detail: "D")
        let interactor = TodoDetailInteractor(
            original: original,
            add: add,
            update: update,
            output: nil
        )
        await interactor.persistIfNeeded(
            current: original,
            draft: TodoDetailDraft(
                title: "New",
                detail: "D",
                isCompleted: false
            )
        )
        XCTAssertEqual(update.updated.count, 1)
    }

    func testPersistSkipsUpdateWhenUnchanged() async {
        let add = AddMock()
        let update = UpdateMock()
        let original = TodoItem(id: 1, title: "Same", detail: "D")
        let interactor = TodoDetailInteractor(
            original: original,
            add: add,
            update: update,
            output: nil
        )
        await interactor.persistIfNeeded(
            current: original,
            draft: TodoDetailDraft(
                title: "Same",
                detail: "D",
                isCompleted: false
            )
        )
        XCTAssertEqual(update.updated.count, 0)
    }
}
