import Foundation

final class TodoDetailRouter: TodoDetailRouterInterface {
    private let onDismiss: () -> Void
    init(onDismiss: @escaping () -> Void) { self.onDismiss = onDismiss }
    func dismiss() { onDismiss() }
}
