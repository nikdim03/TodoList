import Foundation

enum Logger {
    static func log(_ message: String) {
        #if DEBUG
            print("[LOG]", message)
        #endif
    }
    static func logError(_ message: String) {
        #if DEBUG
            print("[ERROR]", message)
        #endif
    }
}
