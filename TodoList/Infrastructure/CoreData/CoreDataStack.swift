import CoreData
import Foundation

final class CoreDataStack {
    static let shared = CoreDataStack()
    let container: NSPersistentContainer
    let backgroundContext: NSManagedObjectContext
    var viewContext: NSManagedObjectContext { container.viewContext }

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(
            name: FormatTemplates.persistentStoreName
        )
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(
                fileURLWithPath: FormatTemplates.devNullPath
            )
        }
        container.loadPersistentStores { _, error in
            if let error {
                fatalError(
                    String(
                        format: FormatTemplates.coreDataUnresolvedError,
                        String(describing: error)
                    )
                )
            }
        }
        container.viewContext.mergePolicy =
            NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
        backgroundContext = container.newBackgroundContext()
        backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        // Ensure background saves merge automatically into viewContext to keep UI in sync without manual fetches.
        backgroundContext.automaticallyMergesChangesFromParent = true
    }
}
