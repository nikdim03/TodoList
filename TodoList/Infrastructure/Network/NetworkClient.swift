import Foundation

final class NetworkClient: RemoteBootstrapService {
    static let shared = NetworkClient()
    private let session: URLSession
    init(session: URLSession = .shared) { self.session = session }

    func fetchTodos() async throws -> [RemoteTodoDTO] {
    guard let url = URL(string: FormatTemplates.remoteTodosURLString) else { throw TaskError.network }
        let (data, response) = try await session.data(from: url)
    guard (response as? HTTPURLResponse)?.statusCode == FormatTemplates.httpStatusOK else {
            throw TaskError.network
        }
        struct Wrapper: Decodable { let todos: [RemoteTodoDTO] }
        do {
            return try JSONDecoder().decode(Wrapper.self, from: data).todos
        } catch { throw TaskError.decode }
    }
}
