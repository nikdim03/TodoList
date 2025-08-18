import Foundation
import SwiftUI

@MainActor
final class TodoListPresenter: ObservableObject, TodoListPresenterInterface,
    TodoListInteractorOutput {
    // Published state observed by SwiftUI View
    @Published private(set) var items: [TodoListItemViewModel] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var isRefreshing: Bool = false
    @Published private(set) var taskCountLabel: String = "0 Задач"  // localized plural label

    private let interactor: TodoListInteractorInterface
    private let router: TodoListRouterInterface
    private var allTasks: [TodoItem] = []  // Source of truth from Interactor
    private var searchDebounceTask: Task<Void, Never>?

    private let speech: SpeechRecognitionService?
    @Published private(set) var isDictating: Bool = false

    init(
        interactor: TodoListInteractorInterface,
        router: TodoListRouterInterface,
        speech: SpeechRecognitionService? = nil
    ) {
        self.interactor = interactor
        self.router = router
        self.speech = speech
    }

    // MARK: - Presenter Interface
    func onAppear() {
        interactor.bootstrap()
        interactor.fetch(search: nil)
    }

    func onAddTapped() { router.routeToDetail(item: nil) }

    func onSearch(_ text: String) {
        searchDebounceTask?.cancel()
        let query = text.trimmingCharacters(in: .whitespacesAndNewlines)
        searchDebounceTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }
            await MainActor.run {
                self?.interactor.fetch(search: query.isEmpty ? nil : query)
            }
        }
    }

    func onToggle(id: Int64) { interactor.toggle(id: id) }
    func onDelete(id: Int64) { interactor.delete(id: id) }
    func onSelect(id: Int64) {
        if let entity = allTasks.first(where: { $0.id == id }) {
            router.routeToDetail(item: entity)
        }
    }
    func onMicTapped() {
        guard let speech else { return }
        if isDictating {
            speech.stop()
            isDictating = false
        } else {
            isDictating = true
            speech.start { [weak self] text in
                guard let self else { return }
                Task { @MainActor in
                    self.onSearch(text)
                }
            }
        }
    }

    func refresh() async { await refreshInternal() }

    private func refreshInternal() async {
        let start = Date()
        isRefreshing = true
        await interactor.refetch()
        let elapsed = Date().timeIntervalSince(start)
        if elapsed < 0.4 {
            try? await Task.sleep(
                nanoseconds: UInt64((0.4 - elapsed) * 1_000_000_000)
            )
        }
        isRefreshing = false
    }

    // MARK: - Interactor Output
    func didChange(tasks: [TodoItem]) {
        allTasks = tasks
        items = tasks.map { task in
            TodoListItemViewModel(
                id: task.id,
                title: task.title,
                detail: task.detail,
                createdDate: task.createdAt.formatted(
                    Date.FormatStyle().day().month(.twoDigits).year(.twoDigits)
                ),
                isCompleted: task.status == .completed
            )
        }
        taskCountLabel = makeCountLabel(tasks.count)
    }

    func didChangeLoading(_ isLoading: Bool) { self.isLoading = isLoading }

    // Exposed for Router to retrieve original entity when navigating
    func entity(for id: Int64) -> TodoItem? { allTasks.first { $0.id == id } }

    // MARK: - Formatting Helpers (UI-specific presentation logic)
    private func makeCountLabel(_ count: Int) -> String {
        let word: String = {
            let rem100 = count % 100
            if rem100 >= 11 && rem100 <= 14 { return "Задач" }
            switch count % 10 {
            case 1: return "Задача"
            case 2, 3, 4: return "Задачи"
            default: return "Задач"
            }
        }()
        return "\(count) \(word)"
    }

    func shareText(for id: Int64) -> String {
        guard let task = entity(for: id) else { return "" }
        let dateStr = task.createdAt.formatted(
            Date.FormatStyle().day().month(.twoDigits).year(.twoDigits)
        )
        let status = task.status == .completed ? "✅ Completed" : "⭕ Pending"
        var lines: [String] = []
        lines.append("")
        lines.append("Название: \(task.title)")
        lines.append("Дата: \(dateStr)")
        lines.append("Статус: \(status)")
        if !task.detail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            lines.append("\n\(task.detail)")
        }
        lines.append("")
        return lines.joined(separator: "\n")
    }
}
