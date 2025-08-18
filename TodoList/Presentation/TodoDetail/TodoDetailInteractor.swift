import Foundation

final class TodoDetailInteractor: TodoDetailInteractorInterface {
    private let add: AddTaskUseCase
    private let update: UpdateTaskUseCase
    private weak var output: TodoDetailInteractorOutput?
    private let original: TodoItem?

    init(
        original: TodoItem?,
        add: AddTaskUseCase,
        update: UpdateTaskUseCase,
        output: TodoDetailInteractorOutput?
    ) {
        self.original = original
        self.add = add
        self.update = update
        self.output = output
    }

    func attach(output: TodoDetailInteractorOutput) { self.output = output }

    func persistIfNeeded(current: TodoItem?, draft: TodoDetailDraft) async {
        if let existing = current {  // update
            if let updated = draft.applying(to: existing), updated != existing {
                try? await update.execute(task: updated)
            }
        } else if original == nil {  // create new
            let trimmedTitle = draft.title.trimmingCharacters(in: .whitespacesAndNewlines)
            let trimmedDetail = draft.detail.trimmingCharacters(in: .whitespacesAndNewlines)
            // Only create if user provided either a title or a detail
            guard !trimmedTitle.isEmpty || !trimmedDetail.isEmpty else { return }
            let titleOrNil = trimmedTitle.isEmpty ? nil : trimmedTitle
            _ = try? await add.execute(detail: trimmedDetail, title: titleOrNil)
        }
    }
}
