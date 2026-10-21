import Foundation

enum TraktConfiguration {
    static var clientID: String {
        ProcessInfo.processInfo.environment["TRAKT_CLIENT_ID"]?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }
}
