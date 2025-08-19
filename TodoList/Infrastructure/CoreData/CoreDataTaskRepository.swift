import CoreData
import Foundation

final class CoreDataTaskRepository: @unchecked Sendable, TaskRepository {
    private let stack: CoreDataStack
    private let appConfig: AppConfig
    private let idGenerator = AtomicCounter()

    init(stack: CoreDataStack = .shared, appConfig: AppConfig = .shared) {
        self.stack = stack
        self.appConfig = appConfig
    }

    func bootstrapIfNeeded(remote: RemoteBootstrapService) async throws {
        guard !appConfig.didBootstrap else { return }
        do {
            let remoteTodos = try await remote.fetchTodos()
            try await persistRemote(remoteTodos)
            appConfig.didBootstrap = true
        } catch { throw TaskError.network }
    }

    private func persistRemote(_ dtos: [RemoteTodoDTO]) async throws {
        let ctx = stack.backgroundContext
        try await ctx.perform {
            for dto in dtos {  // simplistic duplicate check
                let fetch: NSFetchRequest<CDTask> = CDTask.fetchRequest()
                fetch.predicate = NSPredicate(
                    format: FormatTemplates.predicateIdEquals,
                    dto.id
                )
                let exists = try ctx.count(for: fetch) > 0
                if exists { continue }
                let cdTask = CDTask(context: ctx)
                cdTask.id = Int64(dto.id)
                cdTask.title = FormatTemplates.russianTaskTitle(
                    id: Int64(dto.id)
                )
                cdTask.detail = dto.todo
                cdTask.createdAt = Date()
                cdTask.completed = dto.completed
            }
            if ctx.hasChanges { try ctx.save() }
        }
    }

    func tasks(matching search: String?) async throws -> [TodoItem] {
        let ctx = stack.viewContext
        return try await ctx.perform { [weak ctx] in
            guard let ctx else { return [] }
            let fetch: NSFetchRequest<CDTask> = CDTask.fetchRequest()
            var predicates: [NSPredicate] = []
            if let query = search, !query.isEmpty {
                predicates.append(
                    NSPredicate(
                        format: FormatTemplates.predicateTitleOrDetail,
                        query,
                        query
                    )
                )
            }
            fetch.predicate =
                predicates.isEmpty
                ? nil
                : NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
            fetch.sortDescriptors = [
                NSSortDescriptor(key: CoreDataKeys.createdAt, ascending: true)
            ]
            let result = try ctx.fetch(fetch)
            return result.map { $0.toDomain() }
        }
    }

    func add(detail: String, title: String?) async throws -> TodoItem {
        let ctx = stack.backgroundContext
        return try await ctx.perform { [self] in
            let cdTask = CDTask(context: ctx)
            let newId = Int64(self.idGenerator.next())
            let task = TodoItem(
                id: newId,
                title: title,
                detail: detail,
                createdAt: Date(),
                status: .pending
            )
            cdTask.populate(from: task)
            try ctx.save()
            return task
        }
    }

    func update(task: TodoItem) async throws {
        let ctx = stack.backgroundContext
        try await ctx.perform {
            let fetch: NSFetchRequest<CDTask> = CDTask.fetchRequest()
            fetch.predicate = NSPredicate(
                format: FormatTemplates.predicateIdEquals,
                task.id
            )
            guard let existing = try ctx.fetch(fetch).first else {
                throw TaskError.notFound
            }
            existing.populate(from: task)
            try ctx.save()
        }
    }

    func delete(id: Int64) async throws {
        let ctx = stack.backgroundContext
        try await ctx.perform {
            let fetch: NSFetchRequest<CDTask> = CDTask.fetchRequest()
            fetch.predicate = NSPredicate(
                format: FormatTemplates.predicateIdEquals,
                id
            )
            if let existing = try ctx.fetch(fetch).first {
                ctx.delete(existing)
                try ctx.save()
            }
        }
    }

    func toggle(id: Int64) async throws {
        let ctx = stack.backgroundContext
        try await ctx.perform {
            let fetch: NSFetchRequest<CDTask> = CDTask.fetchRequest()
            fetch.predicate = NSPredicate(
                format: FormatTemplates.predicateIdEquals,
                id
            )
            guard let existing = try ctx.fetch(fetch).first else {
                throw TaskError.notFound
            }
            existing.completed.toggle()
            try ctx.save()
        }
    }
}

private final class AtomicCounter {
    private let lock = NSLock()
    private var value: Int64 = 1000
    func next() -> Int64 {
        lock.lock()
        defer { lock.unlock() }
        value += 1
        return value
    }
}

// MARK: - Mapping
extension CDTask {
    func toDomain() -> TodoItem {
        TodoItem(
            id: id,
            title: title ?? FormatTemplates.russianTaskTitle(id: id),
            detail: detail ?? "",
            createdAt: createdAt ?? Date(),
            status: completed ? .completed : .pending
        )
    }
    func populate(from task: TodoItem) {
        id = task.id
        title = task.title
        detail = task.detail
        createdAt = task.createdAt
        completed = task.status == .completed
    }
}
