import Foundation

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

protocol AuthServicing {
    var currentUser: AuthUser? { get }

    @MainActor
    func signUp(email: String, password: String, fullName: String) async throws -> AuthUser

    @MainActor
    func logIn(email: String, password: String) async throws -> AuthUser

    @MainActor
    func signOut()
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

        let newRecord = AuthRecord(id: UUID(), email: normalizedEmail, fullName: trimmedName, password: password)
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
        guard let record = records.first(where: { $0.email == normalizedEmail }) else {
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

    func signOut() {
        currentUser = nil
        storage.saveCurrentUser(nil)
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
    let id: UUID
    let email: String
    let fullName: String
    let password: String

    var authUser: AuthUser {
        AuthUser(id: id, email: email, fullName: fullName)
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

    func loadUsers() -> [AuthRecord] {
        guard let data = defaults.data(forKey: usersKey) else { return [] }
        return (try? decoder.decode([AuthRecord].self, from: data)) ?? []
    }

    func saveUsers(_ records: [AuthRecord]) {
        guard let data = try? encoder.encode(records) else { return }
        defaults.set(data, forKey: usersKey)
    }

    func loadCurrentUser() -> AuthUser? {
        guard let data = defaults.data(forKey: currentUserKey) else { return nil }
        return try? decoder.decode(AuthUser.self, from: data)
    }

    func saveCurrentUser(_ user: AuthUser?) {
        if let user,
           let data = try? encoder.encode(user) {
            defaults.set(data, forKey: currentUserKey)
        } else {
            defaults.removeObject(forKey: currentUserKey)
        }
    }
}
