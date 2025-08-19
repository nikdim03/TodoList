import Foundation
import SwiftUI

final class AppAssembler: ObservableObject {
    static let shared = AppAssembler()
    private init() {}

    // Core singletons
    private lazy var stack = CoreDataStack()
    private lazy var repository: TaskRepository = CoreDataTaskRepository(
        stack: stack
    )

    // Use cases
    private lazy var loadInitialUC = LoadInitialTasksIfNeeded(
        repo: repository,
        remote: NetworkClient.shared
    )
    private lazy var getTasksUC = GetTasks(repo: repository)
    private lazy var addTaskUC = AddTask(repo: repository)
    private lazy var updateTaskUC = UpdateTask(repo: repository)
    private lazy var deleteTaskUC = DeleteTask(repo: repository)
    private lazy var toggleTaskUC = ToggleTaskStatus(repo: repository)

    // MARK: - Feature Builders
    @MainActor
    func makeTodoListModule() -> some View {
        let router = TodoListRouter(assembler: self)
        let interactor = TodoListInteractor(
            loadInitial: loadInitialUC,
            getTasks: getTasksUC,
            toggleTask: toggleTaskUC,
            deleteTask: deleteTaskUC,
            output: nil
        )
        let presenter = TodoListPresenter(
            interactor: interactor,
            router: router,
            // Disable speech recognizer during UI tests to avoid system permission alerts blocking the flow.
            speech: ProcessInfo.processInfo.arguments.contains(
                "UITEST_DISABLE_SPEECH"
            ) ? nil : SystemSpeechRecognizer()
        )
        interactor.attach(output: presenter)
        return TodoListView(presenter: presenter, router: router)
    }

    @MainActor
    func makeTodoDetailModule(item: TodoItem?, onDismiss: @escaping () -> Void)
        -> some View {
        let router = TodoDetailRouter(onDismiss: onDismiss)
        let interactor = TodoDetailInteractor(
            original: item,
            add: addTaskUC,
            update: updateTaskUC,
            output: nil
        )
        let presenter = TodoDetailPresenter(
            original: item,
            interactor: interactor,
            router: router
        )
        interactor.attach(output: presenter)
        return TodoDetailView(presenter: presenter)
    }
}
