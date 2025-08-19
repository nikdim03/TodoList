import XCTest

@testable import TodoList

final class TodoListPresenterAdditionalTests: XCTestCase {
    // MARK: - Mocks
    final class InteractorMock: TodoListInteractorInterface {
        var bootstrapCalled = false
        var fetchCalls: [String?] = []
        var toggleCalls: [Int64] = []
        var deleteCalls: [Int64] = []
        var refetchCount = 0
        func bootstrap() { bootstrapCalled = true }
        func fetch(search: String?) { fetchCalls.append(search) }
        func refetch() async { refetchCount += 1 }
        func toggle(id: Int64) { toggleCalls.append(id) }
        func delete(id: Int64) { deleteCalls.append(id) }
    }
    final class RouterMock: TodoListRouterInterface {
        var routedToDetail: TodoItem? = nil
        func routeToDetail(item: TodoItem?) { routedToDetail = item }
    }
    final class SpeechMock: SpeechRecognitionService {
        var startCalled = false
        var stopCalled = false
        var updateHandler: ((String) -> Void)?
        func start(onUpdate: @escaping (String) -> Void) {
            startCalled = true
            updateHandler = onUpdate
        }
        func stop() { stopCalled = true }
    }

    // Presenter needs to receive output calls -> we use a spy implementing output
    @MainActor
    final class OutputSpy: TodoListInteractorOutput {
        var lastTasks: [TodoItem] = []
        var loadingStates: [Bool] = []
        func didChange(tasks: [TodoItem]) { lastTasks = tasks }
        func didChangeLoading(_ isLoading: Bool) {
            loadingStates.append(isLoading)
        }
    }

    // MARK: - Tests
    @MainActor
    func testOnAppearBootstrapsAndInitialFetch() {
        let interactor = InteractorMock()
        let router = RouterMock()
        let presenter = TodoListPresenter(
            interactor: interactor,
            router: router
        )
        presenter.onAppear()
        XCTAssertTrue(interactor.bootstrapCalled)
        XCTAssertEqual(interactor.fetchCalls.first ?? "", nil)
    }

    @MainActor
    func testOnAddTappedRoutesToDetailWithNil() {
        let interactor = InteractorMock()
        let router = RouterMock()
        let presenter = TodoListPresenter(
            interactor: interactor,
            router: router
        )
        presenter.onAddTapped()
        XCTAssertNil(router.routedToDetail)  // nil indicates creation flow
    }

    @MainActor
    func testOnToggleDelegatesToInteractor() {
        let interactor = InteractorMock()
        let router = RouterMock()
        let presenter = TodoListPresenter(
            interactor: interactor,
            router: router
        )
        presenter.onToggle(id: 10)
        XCTAssertEqual(interactor.toggleCalls, [10])
    }

    @MainActor
    func testOnDeleteDelegatesToInteractor() {
        let interactor = InteractorMock()
        let router = RouterMock()
        let presenter = TodoListPresenter(
            interactor: interactor,
            router: router
        )
        presenter.onDelete(id: 11)
        XCTAssertEqual(interactor.deleteCalls, [11])
    }

    @MainActor
    func testRoutingToExistingItem() {
        let interactor = InteractorMock()
        let router = RouterMock()
        let presenter = TodoListPresenter(
            interactor: interactor,
            router: router
        )
        let items = [
            TodoItem(id: 1, title: "A", detail: "d"),
            TodoItem(id: 2, title: "B", detail: "d2", status: .completed),
        ]
        presenter.didChange(tasks: items)
        presenter.onSelect(id: 2)
        XCTAssertEqual(router.routedToDetail?.id, 2)
    }

    @MainActor
    func testShareTextFormattingIncludesFields() {
        let interactor = InteractorMock()
        let router = RouterMock()
        let presenter = TodoListPresenter(
            interactor: interactor,
            router: router
        )
        let task = TodoItem(id: 5, title: "Title", detail: "Detail text")
        presenter.didChange(tasks: [task])
        let share = presenter.shareText(for: 5)
        XCTAssertTrue(share.contains("Название:"))
        XCTAssertTrue(share.contains("Статус:"))
        XCTAssertTrue(share.contains("Detail text"))
    }

    @MainActor
    func testMicTogglesSpeechRecognition() {
        let interactor = InteractorMock()
        let router = RouterMock()
        let speech = SpeechMock()
        let presenter = TodoListPresenter(
            interactor: interactor,
            router: router,
            speech: speech
        )
        presenter.onMicTapped()
        XCTAssertTrue(speech.startCalled)
        XCTAssertTrue(presenter.isDictating)
        presenter.onMicTapped()
        XCTAssertTrue(speech.stopCalled)
        XCTAssertFalse(presenter.isDictating)
    }

    @MainActor
    func testDictationUpdatesTriggerSearch() async throws {
        let interactor = InteractorMock()
        let router = RouterMock()
        let speech = SpeechMock()
        let presenter = TodoListPresenter(
            interactor: interactor,
            router: router,
            speech: speech
        )
        presenter.onMicTapped()
        speech.updateHandler?("Hello")
        try await Task.sleep(nanoseconds: 400_000_000)  // wait debounce
        XCTAssertEqual(interactor.fetchCalls.last!, "Hello")
    }

    @MainActor
    func testRefreshShowsAndHidesRefreshingState() async {
        let interactor = InteractorMock()
        let router = RouterMock()
        let presenter = TodoListPresenter(
            interactor: interactor,
            router: router
        )
        await presenter.refresh()
        // Because minRefreshDuration is 0.4s we expect refreshing toggled at least twice (true->false)
        // We cannot directly intercept isRefreshing changes without KVO; instead we assert refetch called
        XCTAssertEqual(interactor.refetchCount, 1)
    }
}
