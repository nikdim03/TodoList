import Foundation
import SwiftUI

@MainActor
final class TodoDetailPresenter: ObservableObject, TodoDetailPresenterInterface,
    TodoDetailInteractorOutput {
    @Published private(set) var title: String = ""
    @Published private(set) var detail: String = ""
    @Published private(set) var isCompleted: Bool = false

    private let interactor: TodoDetailInteractorInterface
    private let router: TodoDetailRouterInterface
    private var original: TodoItem?
    private var initialDraft: TodoDetailDraft
    private var closing = false

    init(
        original: TodoItem?,
        interactor: TodoDetailInteractorInterface,
        router: TodoDetailRouterInterface
    ) {
        self.original = original
        self.interactor = interactor
        self.router = router
        self.initialDraft = TodoDetailDraft(item: original)
    }

    var createdAt: Date { original?.createdAt ?? Date() }

    func onAppear() { apply(initialDraft) }
    func onTitleChanged(_ text: String) { title = text }
    func onDetailChanged(_ text: String) { detail = text }
    func onToggleCompleted() { isCompleted.toggle() }
    func onClose() {
        guard !closing else { return }
        closing = true
        Task { @MainActor in
            // Persist can perform background work; we hop back to MainActor for dismissal.
            await persistIfDirty()
            router.dismiss()
        }
    }

    private func currentDraft() -> TodoDetailDraft {
        TodoDetailDraft(title: title, detail: detail, isCompleted: isCompleted)
    }
    private func apply(_ draft: TodoDetailDraft) {
        title = draft.title
        detail = draft.detail
        isCompleted = draft.isCompleted
    }
    private func persistIfDirty() async {
        let draft = currentDraft()
        if draft != initialDraft {
            await interactor.persistIfNeeded(current: original, draft: draft)
        }
    }
}
