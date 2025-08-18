import Foundation

final class AppConfig: @unchecked Sendable {  // UserDefaults wrapper
    static let shared = AppConfig()
    private let defaults = UserDefaults.standard
    private let flagKey = FormatTemplates.bootstrapFlagKey

    var didBootstrap: Bool {
        get { defaults.bool(forKey: flagKey) }
        set { defaults.set(newValue, forKey: flagKey) }
    }
}
