import Foundation

/// Update the values in this file with your Google Sign-In credentials.
/// Only the client ID is required for the integration to work.
///
/// Don't forget to update the reversed client ID placeholder in
/// `DocMakerApp/Info.plist` so the OAuth redirect can complete successfully.
enum GoogleSignInConfig {
    /// The OAuth client ID generated in the Google Cloud Console.
    /// Example: "1234567890-abc123def456.apps.googleusercontent.com"
    static var clientID: String { clientIDStorage }

    /// Indicates whether a client ID value has been provided.
    static var isClientIDConfigured: Bool {
        !clientID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// Store the client ID in one place so the developer can update it easily.
    private static let clientIDStorage = ""
}
