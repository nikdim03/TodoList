import XCTest

@testable import TodoList

final class ShareTextFormattingTests: XCTestCase {
    final class InteractorMock: TodoListInteractorInterface {
        func bootstrap() {}
        func fetch(search: String?) {}
        func refetch() async {}
        func toggle(id: Int64) {}
        func delete(id: Int64) {}
    }
    final class RouterMock: TodoListRouterInterface {
        func routeToDetail(item: TodoItem?) {}
    }

    @MainActor
    func testShareTextForCompletedTaskIncludesStatusAndDetail() {
        let presenter = TodoListPresenter(
            interactor: InteractorMock(),
            router: RouterMock()
        )
        let completed = TodoItem(
            id: 7,
            title: "Done",
            detail: "All set",
            status: .completed
        )
        presenter.didChange(tasks: [completed])
        let text = presenter.shareText(for: 7)
        XCTAssertTrue(text.contains("Название:"))
        XCTAssertTrue(text.contains("Статус:"))
        XCTAssertTrue(text.contains("Выполнено"))
        XCTAssertTrue(text.contains("All set"))
    }
}
