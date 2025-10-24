import Foundation
#if canImport(GoogleSignIn)
import GoogleSignIn
#endif

struct AuthUser: Codable, Identifiable, Equatable {
    let id: UUID
    let email: String
    let fullName: String
}

enum AuthError: LocalizedError, Equatable {
    case invalidEmail
    case weakPassword
    case missingFullName
    case userAlreadyExists
    case userNotFound
    case incorrectPassword

    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "Please enter a valid email address."
        case .weakPassword:
            return "Passwords must be at least 8 characters long."
        case .missingFullName:
            return "Let us know who you are by adding your full name."
        case .userAlreadyExists:
            return "An account with this email already exists. Try logging in instead."
        case .userNotFound:
            return "We couldn’t find an account with that email."
        case .incorrectPassword:
            return "The password you entered is incorrect."
        }
    }
}

struct AppleSignInCredentials {
    let userIdentifier: String
    let email: String?
    let fullNameComponents: PersonNameComponents?

    var formattedFullName: String? {
        guard let fullNameComponents else { return nil }
        let formatter = PersonNameComponentsFormatter()
        formatter.style = .medium
        let name = formatter.string(from: fullNameComponents).trimmingCharacters(in: .whitespacesAndNewlines)
        return name.isEmpty ? nil : name
    }
}

struct GoogleSignInCredentials {
    let userID: String
    let email: String?
    let fullName: String?

    var normalizedFullName: String? {
        guard let trimmed = fullName?.trimmingCharacters(in: .whitespacesAndNewlines), !trimmed.isEmpty else {
            return nil
        }
        return trimmed
    }
}

protocol AuthServicing {
    var currentUser: AuthUser? { get }

    @MainActor
    func signUp(email: String, password: String, fullName: String) async throws -> AuthUser

    @MainActor
    func logIn(email: String, password: String) async throws -> AuthUser

    @MainActor
    func signOut()

    @MainActor
    func signInWithApple(_ credentials: AppleSignInCredentials) async throws -> AuthUser

    @MainActor
    func signInWithGoogle(_ credentials: GoogleSignInCredentials) async throws -> AuthUser
}

@MainActor
final class AuthService: AuthServicing {
    static let shared = AuthService()

    private let storage: AuthStorage
    private(set) var currentUser: AuthUser?

    init(storage: AuthStorage = AuthStorage()) {
        self.storage = storage
        self.currentUser = storage.loadCurrentUser()
    }

    func signUp(email: String, password: String, fullName: String) async throws -> AuthUser {
        let normalizedEmail = Self.normalize(email: email)
        let trimmedName = fullName.trimmingCharacters(in: .whitespacesAndNewlines)

        try validate(email: normalizedEmail, password: password, fullName: trimmedName)

        try await Task.sleep(nanoseconds: 400_000_000) // Simulate network latency

        var records = storage.loadUsers()
        if records.contains(where: { $0.email == normalizedEmail }) {
            throw AuthError.userAlreadyExists
        }

        let newRecord = AuthRecord(
            id: UUID(),
            email: normalizedEmail,
            fullName: trimmedName,
            password: password,
            provider: .emailPassword
        )
        records.append(newRecord)
        storage.saveUsers(records)

        let user = newRecord.authUser
        currentUser = user
        storage.saveCurrentUser(user)
        return user
    }

    func logIn(email: String, password: String) async throws -> AuthUser {
        let normalizedEmail = Self.normalize(email: email)

        try await Task.sleep(nanoseconds: 300_000_000) // Simulate network latency

        let records = storage.loadUsers()
        guard let record = records.first(where: { $0.email == normalizedEmail && $0.provider == .emailPassword }) else {
            throw AuthError.userNotFound
        }

        guard record.password == password else {
            throw AuthError.incorrectPassword
        }

        let user = record.authUser
        currentUser = user
        storage.saveCurrentUser(user)
        return user
    }

    func signInWithApple(_ credentials: AppleSignInCredentials) async throws -> AuthUser {
        try await Task.sleep(nanoseconds: 300_000_000) // Simulate network latency

        var records = storage.loadUsers()

        if let index = records.firstIndex(where: { $0.appleUserIdentifier == credentials.userIdentifier }) {
            var existingRecord = records[index]

            if let email = credentials.email {
                existingRecord.email = Self.normalize(email: email)
            }

            if let name = credentials.formattedFullName {
                existingRecord.fullName = name
            }

            records[index] = existingRecord
            storage.saveUsers(records)

            let user = existingRecord.authUser
            currentUser = user
            storage.saveCurrentUser(user)
            return user
        }

        let normalizedEmail: String
        if let email = credentials.email {
            normalizedEmail = Self.normalize(email: email)
        } else {
            normalizedEmail = Self.normalize(email: "\(credentials.userIdentifier)@privaterelay.appleid.com")
        }

        let resolvedName = credentials.formattedFullName ?? "Apple User"

        let newRecord = AuthRecord(
            id: UUID(),
            email: normalizedEmail,
            fullName: resolvedName,
            password: nil,
            provider: .apple,
            appleUserIdentifier: credentials.userIdentifier
        )

        records.append(newRecord)
        storage.saveUsers(records)

        let user = newRecord.authUser
        currentUser = user
        storage.saveCurrentUser(user)
        return user
    }

    func signInWithGoogle(_ credentials: GoogleSignInCredentials) async throws -> AuthUser {
        try await Task.sleep(nanoseconds: 300_000_000) // Simulate network latency

        var records = storage.loadUsers()

        if let index = records.firstIndex(where: { $0.googleUserIdentifier == credentials.userID }) {
            var existingRecord = records[index]

            if let email = credentials.email {
                existingRecord.email = Self.normalize(email: email)
            }

            if let name = credentials.normalizedFullName {
                existingRecord.fullName = name
            }

            records[index] = existingRecord
            storage.saveUsers(records)

            let user = existingRecord.authUser
            currentUser = user
            storage.saveCurrentUser(user)
            return user
        }

        let normalizedEmail: String
        if let email = credentials.email {
            normalizedEmail = Self.normalize(email: email)
        } else {
            normalizedEmail = Self.normalize(email: "\(credentials.userID)@users.noreply.google.com")
        }

        let resolvedName = credentials.normalizedFullName ?? "Google User"

        let newRecord = AuthRecord(
            id: UUID(),
            email: normalizedEmail,
            fullName: resolvedName,
            password: nil,
            provider: .google,
            appleUserIdentifier: nil,
            googleUserIdentifier: credentials.userID
        )

        records.append(newRecord)
        storage.saveUsers(records)

        let user = newRecord.authUser
        currentUser = user
        storage.saveCurrentUser(user)
        return user
    }

    func signOut() {
        currentUser = nil
        storage.saveCurrentUser(nil)
#if canImport(GoogleSignIn)
        GIDSignIn.sharedInstance.signOut()
#endif
    }

    private func validate(email: String, password: String, fullName: String) throws {
        guard Self.isValidEmail(email) else {
            throw AuthError.invalidEmail
        }

        guard password.count >= 8 else {
            throw AuthError.weakPassword
        }

        guard !fullName.isEmpty else {
            throw AuthError.missingFullName
        }
    }

    private static func normalize(email: String) -> String {
        email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    private static func isValidEmail(_ email: String) -> Bool {
        let pattern = #"^\S+@\S+\.\S+$"#
        return email.range(of: pattern, options: .regularExpression) != nil
    }
}

private struct AuthRecord: Codable {
    enum Provider: String, Codable {
        case emailPassword
        case apple
        case google
    }

    enum CodingKeys: String, CodingKey {
        case id
        case email
        case fullName
        case password
        case provider
        case appleUserIdentifier
        case googleUserIdentifier
    }

    let id: UUID
    var email: String
    var fullName: String
    var password: String?
    var provider: Provider
    var appleUserIdentifier: String?
    var googleUserIdentifier: String?

    var authUser: AuthUser {
        AuthUser(id: id, email: email, fullName: fullName)
    }

    init(
        id: UUID,
        email: String,
        fullName: String,
        password: String?,
        provider: Provider,
        appleUserIdentifier: String? = nil,
        googleUserIdentifier: String? = nil
    ) {
        self.id = id
        self.email = email
        self.fullName = fullName
        self.password = password
        self.provider = provider
        self.appleUserIdentifier = appleUserIdentifier
        self.googleUserIdentifier = googleUserIdentifier
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        email = try container.decode(String.self, forKey: .email)
        fullName = try container.decode(String.self, forKey: .fullName)
        password = try container.decodeIfPresent(String.self, forKey: .password)
        provider = try container.decodeIfPresent(Provider.self, forKey: .provider) ?? .emailPassword
        appleUserIdentifier = try container.decodeIfPresent(String.self, forKey: .appleUserIdentifier)
        googleUserIdentifier = try container.decodeIfPresent(String.self, forKey: .googleUserIdentifier)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(email, forKey: .email)
        try container.encode(fullName, forKey: .fullName)
        try container.encodeIfPresent(password, forKey: .password)
        try container.encode(provider, forKey: .provider)
        try container.encodeIfPresent(appleUserIdentifier, forKey: .appleUserIdentifier)
        try container.encodeIfPresent(googleUserIdentifier, forKey: .googleUserIdentifier)
    }
}

struct AuthStorage {
    private let defaults: UserDefaults
    private let usersKey = "com.docmaker.auth.users"
    private let currentUserKey = "com.docmaker.auth.currentUser"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    fileprivate func loadUsers() -> [AuthRecord] {
        guard let data = defaults.data(forKey: usersKey) else { return [] }
        return (try? decoder.decode([AuthRecord].self, from: data)) ?? []
    }

    fileprivate func saveUsers(_ records: [AuthRecord]) {
        guard let data = try? encoder.encode(records) else { return }
        defaults.set(data, forKey: usersKey)
    }

    func loadCurrentUser() -> AuthUser? {
        guard let data = defaults.data(forKey: currentUserKey) else { return nil }
        return try? decoder.decode(AuthUser.self, from: data)
    }

    fileprivate func saveCurrentUser(_ user: AuthUser?) {
        if let user,
           let data = try? encoder.encode(user) {
            defaults.set(data, forKey: currentUserKey)
        } else {
            defaults.removeObject(forKey: currentUserKey)
        }
    }
}
