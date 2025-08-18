import Foundation
import SwiftUI

// MARK: - Draft + ViewModel
struct TodoDetailDraft: Equatable {
    var title: String
    var detail: String
    var isCompleted: Bool
    init(item: TodoItem?) {
        title = item?.title ?? ""
        detail = item?.detail ?? ""
        isCompleted = item?.status == .completed
    }
    func applying(to original: TodoItem?) -> TodoItem? {
        guard var original else { return nil }
        original.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        original.detail = detail
        original.status = isCompleted ? .completed : .pending
        return original
    }
}

// MARK: - Contracts
@MainActor
protocol TodoDetailPresenterInterface: AnyObject {
    var title: String { get }
    var detail: String { get }
    var isCompleted: Bool { get }
    var createdAt: Date { get }
    func onAppear()
    func onTitleChanged(_ text: String)
    func onDetailChanged(_ text: String)
    func onToggleCompleted()
    func onClose()
}

protocol TodoDetailInteractorInterface: AnyObject {
    func persistIfNeeded(current: TodoItem?, draft: TodoDetailDraft) async
}
@MainActor
protocol TodoDetailInteractorOutput: AnyObject {}
@MainActor
protocol TodoDetailRouterInterface: AnyObject { func dismiss() }
