import Foundation

enum AppConfiguration {
    static var googleClientID: String? {
        Bundle.main.object(forInfoDictionaryKey: "GIDClientID") as? String
    }
}
