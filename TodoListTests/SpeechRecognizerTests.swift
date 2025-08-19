import XCTest

@testable import TodoList

final class SpeechRecognizerTests: XCTestCase {
    func testInitSetsEmptyTranscript() {
        let recognizer = SystemSpeechRecognizer()
        XCTAssertEqual(recognizer.transcript, "")
    }

    func testStopIsIdempotent() {
        let recognizer = SystemSpeechRecognizer()
        recognizer.stop()
        recognizer.stop()
        XCTAssertEqual(recognizer.transcript, "")
    }
}
