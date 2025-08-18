import Foundation

final class TodoListInteractor: TodoListInteractorInterface {
    // Dependencies (Use Cases)
    private let loadInitial: LoadInitialTasksIfNeededUseCase
    private let getTasks: GetTasksUseCase
    private let toggleTask: ToggleTaskStatusUseCase
    private let deleteTask: DeleteTaskUseCase
    private weak var output: TodoListInteractorOutput?
    private var currentSearch: String?

    init(
        loadInitial: LoadInitialTasksIfNeededUseCase,
        getTasks: GetTasksUseCase,
        toggleTask: ToggleTaskStatusUseCase,
        deleteTask: DeleteTaskUseCase,
        output: TodoListInteractorOutput?
    ) {
        self.loadInitial = loadInitial
        self.getTasks = getTasks
        self.toggleTask = toggleTask
        self.deleteTask = deleteTask
        self.output = output
    }

    func attach(output: TodoListInteractorOutput) { self.output = output }

    func bootstrap() {
        Task {
            try? await loadInitial.execute()
            await fetchInternal()
        }
    }

    func fetch(search: String?) {
        currentSearch = search
        Task { await fetchInternal() }
    }

    func refetch() async { await fetchInternal() }

    private func fetchInternal() async {
        await MainActor.run { output?.didChangeLoading(true) }
        do {
            let tasks = try await getTasks.execute(search: currentSearch)
            await MainActor.run { output?.didChange(tasks: tasks) }
        } catch {
            // In a more robust app we would propagate error for Presenter to convert to UI state.
            Logger.logError(String(format: FormatTemplates.fetchTasksFailed, String(describing: error)))
        }
        await MainActor.run { output?.didChangeLoading(false) }
    }

    func toggle(id: Int64) {
        Task {
            try? await toggleTask.execute(id: id)
            await fetchInternal()
        }
    }

    func delete(id: Int64) {
        Task {
            try? await deleteTask.execute(id: id)
            await fetchInternal()
        }
    }
}
