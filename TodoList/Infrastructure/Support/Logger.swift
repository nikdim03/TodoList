import Foundation

enum Logger {
    static func log(_ message: String) {
        #if DEBUG
        print(FormatTemplates.logPrefix, message)
        #endif
    }
    static func logError(_ message: String) {
        #if DEBUG
        print(FormatTemplates.errorPrefix, message)
        #endif
    }
}
