import XCTest

@testable import TodoList

final class TodoListInteractorTests: XCTestCase {
    // MARK: - Use Case Mocks
    actor CallLog { var entries: [String] = [] }
    final class LoadInitialMock: LoadInitialTasksIfNeededUseCase {
        var executed = false
        func execute() async throws { executed = true }
    }
    final class GetTasksMock: GetTasksUseCase {
        var providedSearches: [String?] = []
        var result: [TodoItem] = []
        func execute(search: String?) async throws -> [TodoItem] {
            providedSearches.append(search)
            return result
        }
    }
    final class ToggleMock: ToggleTaskStatusUseCase {
        var toggledIds: [Int64] = []
        func execute(id: Int64) async throws { toggledIds.append(id) }
    }
    final class DeleteMock: DeleteTaskUseCase {
        var deletedIds: [Int64] = []
        func execute(id: Int64) async throws { deletedIds.append(id) }
    }

    @MainActor
    final class OutputSpy: TodoListInteractorOutput {
        var tasksSnapshots: [[TodoItem]] = []
        var loadingStates: [Bool] = []
        func didChange(tasks: [TodoItem]) { tasksSnapshots.append(tasks) }
        func didChangeLoading(_ isLoading: Bool) {
            loadingStates.append(isLoading)
        }
    }

    @MainActor
    func testBootstrapLoadsAndFetches() async throws {
        let load = LoadInitialMock()
        let get = GetTasksMock()
        let toggle = ToggleMock()
        let del = DeleteMock()
        let output = OutputSpy()
        get.result = []
        let interactor = TodoListInteractor(
            loadInitial: load,
            getTasks: get,
            toggleTask: toggle,
            deleteTask: del,
            output: output
        )
        interactor.bootstrap()
        try await Task.sleep(nanoseconds: 200_000_000)
        XCTAssertTrue(load.executed)
        XCTAssertEqual(get.providedSearches.count, 1)
        XCTAssertEqual(output.loadingStates.first, true)
        XCTAssertEqual(output.loadingStates.last, false)
    }

    @MainActor
    func testFetchWithSearchPersistsSearchFilter() async throws {
        let load = LoadInitialMock()
        let get = GetTasksMock()
        let toggle = ToggleMock()
        let del = DeleteMock()
        let output = OutputSpy()
        get.result = []
        let interactor = TodoListInteractor(
            loadInitial: load,
            getTasks: get,
            toggleTask: toggle,
            deleteTask: del,
            output: output
        )
        interactor.fetch(search: "abc")
        try await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertEqual(get.providedSearches.last!, "abc")
    }

    @MainActor
    func testToggleTriggersReload() async throws {
        let load = LoadInitialMock()
        let get = GetTasksMock()
        let toggle = ToggleMock()
        let del = DeleteMock()
        let output = OutputSpy()
        get.result = [TodoItem(id: 1, title: "One", detail: "d")]
        let interactor = TodoListInteractor(
            loadInitial: load,
            getTasks: get,
            toggleTask: toggle,
            deleteTask: del,
            output: output
        )
        interactor.toggle(id: 1)
        try await Task.sleep(nanoseconds: 150_000_000)
        XCTAssertEqual(toggle.toggledIds, [1])
        XCTAssertGreaterThanOrEqual(output.tasksSnapshots.count, 1)
    }

    @MainActor
    func testDeleteTriggersReload() async throws {
        let load = LoadInitialMock()
        let get = GetTasksMock()
        let toggle = ToggleMock()
        let del = DeleteMock()
        let output = OutputSpy()
        get.result = []
        let interactor = TodoListInteractor(
            loadInitial: load,
            getTasks: get,
            toggleTask: toggle,
            deleteTask: del,
            output: output
        )
        interactor.delete(id: 2)
        try await Task.sleep(nanoseconds: 150_000_000)
        XCTAssertEqual(del.deletedIds, [2])
        XCTAssertGreaterThanOrEqual(output.loadingStates.count, 2)  // true then false
    }
}
