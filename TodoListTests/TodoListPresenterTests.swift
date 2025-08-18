import XCTest

@testable import TodoList

final class TodoListPresenterTests: XCTestCase {
    private final class InteractorMock: TodoListInteractorInterface {
        var fetchCalls: [String?] = []
        func bootstrap() {}
        func fetch(search: String?) { fetchCalls.append(search) }
        func refetch() async {}
        func toggle(id: Int64) {}
        func delete(id: Int64) {}
    }
    private final class RouterMock: TodoListRouterInterface {
        func routeToDetail(item: TodoItem?) {}
    }

    @MainActor
    func testSearchDebounceFiresLatest() async throws {
        let interactor = InteractorMock()
        let router = RouterMock()
        let presenter = TodoListPresenter(
            interactor: interactor,
            router: router
        )
        presenter.onSearch("a")
        presenter.onSearch("ab")
        presenter.onSearch("abc")
        try? await Task.sleep(nanoseconds: 400_000_000)
        XCTAssertEqual(interactor.fetchCalls.last!, "abc")
    }
}
