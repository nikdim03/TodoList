import Darwin
import XCTest

@testable import TodoList

final class LoggerTests: XCTestCase {

    func testLogPrintsMessageWithPrefix() throws {
        #if !DEBUG
            throw XCTSkip("Logger only prints in DEBUG builds.")
        #endif

        let output = captureStdout {
            Logger.log("Hello World")
        }

        XCTAssertTrue(output.contains(FormatTemplates.logPrefix))
        XCTAssertTrue(output.contains("Hello World"))
    }

    func testLogErrorPrintsMessageWithErrorPrefix() throws {
        #if !DEBUG
            throw XCTSkip("Logger only prints in DEBUG builds.")
        #endif

        let output = captureStdout {
            Logger.logError("Something went wrong")
        }

        XCTAssertTrue(output.contains(FormatTemplates.errorPrefix))
        XCTAssertTrue(output.contains("Something went wrong"))
    }

    // MARK: - Helper

    /// Captures stdout during `block` execution and returns it as a String.
    private func captureStdout(_ block: () -> Void) -> String {
        // Save original stdout
        let originalStdout = dup(STDOUT_FILENO)

        // Pipe for capturing
        let pipe = Pipe()

        // Redirect stdout to pipe's write end
        dup2(pipe.fileHandleForWriting.fileDescriptor, STDOUT_FILENO)

        // Make stdout unbuffered to avoid waiting on flushes
        setvbuf(stdout, nil, _IONBF, 0)

        // Perform the work
        block()

        // Ensure everything is written, then close writer side so reader hits EOF
        fflush(stdout)
        pipe.fileHandleForWriting.closeFile()

        // Restore stdout immediately (before reading) to avoid accidental writes into the pipe
        dup2(originalStdout, STDOUT_FILENO)
        close(originalStdout)

        // Read all captured data
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8) ?? ""
    }
}
