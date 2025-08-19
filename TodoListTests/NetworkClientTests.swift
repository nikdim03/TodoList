import XCTest

@testable import TodoList

final class NetworkClientTests: XCTestCase {
    final class StubURLProtocol: URLProtocol {
        static var handler: ((URLRequest) throws -> (HTTPURLResponse, Data))?
        override class func canInit(with request: URLRequest) -> Bool { true }
        override class func canonicalRequest(for request: URLRequest)
            -> URLRequest
        { request }
        override func startLoading() {
            guard let handler = StubURLProtocol.handler else { return }
            do {
                let (response, data) = try handler(request)
                client?.urlProtocol(
                    self,
                    didReceive: response,
                    cacheStoragePolicy: .notAllowed
                )
                client?.urlProtocol(self, didLoad: data)
                client?.urlProtocolDidFinishLoading(self)
            } catch {
                client?.urlProtocol(self, didFailWithError: error)
            }
        }
        override func stopLoading() {}
    }

    func makeClient(statusCode: Int = 200, json: String) -> NetworkClient {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [StubURLProtocol.self]
        StubURLProtocol.handler = { request in
            let url = request.url ?? URL(string: "https://example.com")!
            let resp = HTTPURLResponse(
                url: url,
                statusCode: statusCode,
                httpVersion: nil,
                headerFields: nil
            )!
            return (resp, Data(json.utf8))
        }
        let session = URLSession(configuration: config)
        return NetworkClient(session: session)
    }

    func testFetchTodosSuccessDecodes() async throws {
        let json = """
            {"todos":[{"id":1,"todo":"Task 1","completed":false,"userId":7}]}
            """
        let client = makeClient(json: json)
        let todos = try await client.fetchTodos()
        XCTAssertEqual(todos.count, 1)
        XCTAssertEqual(todos.first?.id, 1)
        XCTAssertEqual(todos.first?.todo, "Task 1")
    }

    func testFetchTodosBadStatusThrowsNetwork() async {
        let json = "{}"
        let client = makeClient(statusCode: 500, json: json)
        do {
            _ = try await client.fetchTodos()
            XCTFail("Expected error")
        } catch {
            XCTAssertEqual(error as? TaskError, TaskError.network)
        }
    }

    func testFetchTodosDecodeFailureThrowsDecode() async {
        let json = "{"  // invalid JSON
        let client = makeClient(json: json)
        do {
            _ = try await client.fetchTodos()
            XCTFail("Expected decode error")
        } catch {
            XCTAssertEqual(error as? TaskError, TaskError.decode)
        }
    }
}
