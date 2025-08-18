import Foundation
import SwiftUI

// MARK: - View Models
struct TodoListItemViewModel: Identifiable, Equatable {
    let id: Int64
    let title: String
    let detail: String
    let createdDate: String
    let isCompleted: Bool
}

// MARK: - VIPER Contracts
// implemented indirectly via Presenter @Published state observed by SwiftUI View
protocol TodoListViewInterface: AnyObject {
    func display(items: [TodoListItemViewModel])
    func setLoading(_ loading: Bool)
}

@MainActor
protocol TodoListPresenterInterface: AnyObject {
    var items: [TodoListItemViewModel] { get }
    var isLoading: Bool { get }
    var isRefreshing: Bool { get }
    func onAppear()
    func onAddTapped()
    func onSearch(_ text: String)
    func onToggle(id: Int64)
    func onDelete(id: Int64)
    func onSelect(id: Int64)
    func refresh() async
}

protocol TodoListInteractorInterface: AnyObject {
    func bootstrap()
    func fetch(search: String?)
    func refetch() async
    func toggle(id: Int64)
    func delete(id: Int64)
}

@MainActor
protocol TodoListInteractorOutput: AnyObject {
    func didChange(tasks: [TodoItem])
    func didChangeLoading(_ isLoading: Bool)
}

@MainActor
protocol TodoListRouterInterface: AnyObject {
    func routeToDetail(item: TodoItem?)
}

// MARK: - Auxiliary Service Abstraction
// Feature-level dependency for dictation. Concrete implementation lives in Infrastructure.
protocol SpeechRecognitionService: AnyObject {
    func start(onUpdate: @escaping (String) -> Void)
    func stop()
}
