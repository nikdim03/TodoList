import XCTest

@testable import TodoList

final class TodoDetailPresenterTests: XCTestCase {
    final class InteractorMock: TodoDetailInteractorInterface {
        var persistCalls: [(TodoItem?, TodoDetailDraft)] = []
        func persistIfNeeded(current: TodoItem?, draft: TodoDetailDraft) async {
            persistCalls.append((current, draft))
        }
    }
    final class RouterMock: TodoDetailRouterInterface {
        var dismissCount = 0
        func dismiss() { dismissCount += 1 }
    }

    @MainActor
    func testOnAppearLoadsInitialDraft() {
        let original = TodoItem(id: 1, title: "Title", detail: "Detail")
        let interactor = InteractorMock()
        let router = RouterMock()
        let presenter = TodoDetailPresenter(
            original: original,
            interactor: interactor,
            router: router
        )
        presenter.onAppear()
        XCTAssertEqual(presenter.title, "Title")
        XCTAssertEqual(presenter.detail, "Detail")
    }

    @MainActor
    func testClosePersistsWhenDirty() async {
        let original = TodoItem(id: 2, title: "Old", detail: "Old detail")
        let interactor = InteractorMock()
        let router = RouterMock()
        let presenter = TodoDetailPresenter(
            original: original,
            interactor: interactor,
            router: router
        )
        presenter.onAppear()
        presenter.onTitleChanged("New")
        presenter.onClose()
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertEqual(interactor.persistCalls.count, 1)
        XCTAssertEqual(router.dismissCount, 1)
    }

    @MainActor
    func testCloseDoesNotPersistWhenUnchanged() async {
        let original = TodoItem(id: 3, title: "Same", detail: "Same")
        let interactor = InteractorMock()
        let router = RouterMock()
        let presenter = TodoDetailPresenter(
            original: original,
            interactor: interactor,
            router: router
        )
        presenter.onAppear()
        presenter.onClose()
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertEqual(interactor.persistCalls.count, 0)
        XCTAssertEqual(router.dismissCount, 1)
    }

    @MainActor
    func testToggleCompletedChangesState() {
        let interactor = InteractorMock()
        let router = RouterMock()
        let presenter = TodoDetailPresenter(
            original: nil,
            interactor: interactor,
            router: router
        )
        presenter.onAppear()
        XCTAssertFalse(presenter.isCompleted)
        presenter.onToggleCompleted()
        XCTAssertTrue(presenter.isCompleted)
    }
}
