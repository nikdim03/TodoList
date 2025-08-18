import CoreData
import Foundation

final class CoreDataStack {
    static let shared = CoreDataStack()
    let container: NSPersistentContainer
    let backgroundContext: NSManagedObjectContext
    var viewContext: NSManagedObjectContext { container.viewContext }

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "TodoList")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(
                fileURLWithPath: "/dev/null"
            )
        }
        container.loadPersistentStores { _, error in
            if let error { fatalError("Unresolved Core Data error: \(error)") }
        }
        container.viewContext.mergePolicy =
            NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
        backgroundContext = container.newBackgroundContext()
        backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
}
