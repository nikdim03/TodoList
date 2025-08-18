import Foundation
import SwiftUI

@MainActor
final class TodoListRouter: ObservableObject, TodoListRouterInterface {
    @Published var path: [TodoListRoute] = []
    private weak var assembler: AppAssembler?

    init(assembler: AppAssembler) { self.assembler = assembler }

    func routeToDetail(item: TodoItem?) { path.append(.detail(item?.id)) }

    // Build destination views by delegating to Assembler keeping Router tiny.
    @ViewBuilder
    func destination(for route: TodoListRoute, presenter: TodoListPresenter)
        -> some View {
        switch route {
        case .detail(let id):
            let todo = id.flatMap { presenter.entity(for: $0) }
            if let assembler {
                assembler.makeTodoDetailModule(item: todo) { [weak self] in
                    self?.path.removeLast()
                }
            }
        }
    }
}

enum TodoListRoute: Hashable { case detail(Int64?) }

// Expose a controlled accessor to original entity (keeps conversion logic in Presenter)
// No presenter extensions – presenter now exposes entity(for:) directly.
// extension TodoListPresenter {
//     fileprivate func entity(for id: Int64) -> TodoItem? { allTasks.first { $0.id == id } }
// }
