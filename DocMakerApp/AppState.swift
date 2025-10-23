import SwiftUI
import Combine

enum AppRoute: Hashable {
    case signUp
    case logIn
    case home
    case primaryPerson
    case spouse
    case children
    case trustee(index: Int)
    case reviewInfo
    case legalConsent
    case generateDocs
    case documentsList
    case documentDetail(id: UUID)
    case payment
    case referFriend
    case contact
    case faq
    case askAI
    case howItWorks
}

@available(iOS 16.0, *)
@MainActor
final class AppState: ObservableObject {
    @Published var path = NavigationPath()

    @Published var signUpData = SignUpData()
    @Published var logInData = LogInData()
    @Published private(set) var authenticatedUser: AuthUser?
    @Published var authError: String?
    @Published var isAuthenticating = false
    @Published var primaryPerson = PersonInfo()
    @Published var spouse = SpouseInfo()
    @Published var children: [ChildInfo] = [ChildInfo(), ChildInfo(), ChildInfo()]
    @Published private(set) var trustees: [TrusteeInfo] = [TrusteeInfo(order: 1)]
    @Published private(set) var generatedDocuments: [DocumentMetadata] = []
    @Published var selectedDocumentID: UUID?

    private var cancellables = Set<AnyCancellable>()
    private let documentStorage: DocumentStorage
    private let authService: AuthServicing

    init(documentStorage: DocumentStorage = .shared, authService: AuthServicing = AuthService.shared) {
        self.documentStorage = documentStorage
        self.authService = authService
        self.generatedDocuments = documentStorage.documents
        self.authenticatedUser = authService.currentUser

        documentStorage.$documents
            .receive(on: DispatchQueue.main)
            .sink { [weak self] documents in
                self?.generatedDocuments = documents
            }
            .store(in: &cancellables)

        if authenticatedUser != nil {
            path.append(.home)
        }
    }

    var canAttemptSignUp: Bool {
        !signUpData.email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !signUpData.password.isEmpty &&
        !signUpData.fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var canAttemptLogIn: Bool {
        !logInData.email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !logInData.password.isEmpty
    }

    func push(_ route: AppRoute) {
        path.append(route)
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path = NavigationPath()
    }

    func navigateToHome() {
        path = NavigationPath()
        path.append(AppRoute.home)
    }

    func clearAuthError() {
        authError = nil
    }

    func signOut() {
        authService.signOut()
        authenticatedUser = nil
        authError = nil
        isAuthenticating = false
        signUpData = SignUpData()
        logInData = LogInData()
        popToRoot()
    }

    func signUp() async {
        guard !isAuthenticating else { return }

        authError = nil
        isAuthenticating = true
        let data = signUpData

        do {
            let user = try await authService.signUp(email: data.email, password: data.password, fullName: data.fullName)
            authenticatedUser = user
            signUpData.password = ""
            signUpData.email = user.email
            signUpData.fullName = user.fullName
            logInData = LogInData(email: user.email, password: "")
            navigateToHome()
        } catch {
            authError = error.localizedDescription
        }

        isAuthenticating = false
    }

    func logIn() async {
        guard !isAuthenticating else { return }

        authError = nil
        isAuthenticating = true
        let data = logInData

        do {
            let user = try await authService.logIn(email: data.email, password: data.password)
            authenticatedUser = user
            logInData = LogInData(email: user.email, password: "")
            navigateToHome()
        } catch {
            authError = error.localizedDescription
        }

        isAuthenticating = false
    }

    func startTrusteeFlow() {
        if trustees.isEmpty {
            trustees = [TrusteeInfo(order: 1)]
        }
        push(.trustee(index: 0))
    }

    func trustee(at index: Int) -> Binding<TrusteeInfo> {
        Binding<TrusteeInfo> {
            guard self.trustees.indices.contains(index) else { return TrusteeInfo(order: index + 1) }
            return self.trustees[index]
        } set: { [self] newValue in
            if self.trustees.indices.contains(index) {
                self.trustees[index] = newValue
            }
        }
    }

    @discardableResult
    func addTrustee() -> Int {
        let nextOrder = trustees.count + 1
        trustees.append(TrusteeInfo(order: nextOrder))
        return trustees.count - 1
    }

    func removeTrustee(at index: Int) {
        guard trustees.indices.contains(index) else { return }
        trustees.remove(at: index)
        for idx in trustees.indices {
            trustees[idx].order = idx + 1
        }
    }

    func clearChildren() {
        children = [ChildInfo(), ChildInfo(), ChildInfo()]
    }

    func resetAfterCompletion() {
        signUpData = SignUpData()
        logInData = LogInData(email: authenticatedUser?.email ?? "", password: "")
        primaryPerson = PersonInfo()
        spouse = SpouseInfo()
        children = [ChildInfo(), ChildInfo(), ChildInfo()]
        trustees = [TrusteeInfo(order: 1)]
        selectedDocumentID = nil
        popToRoot()
    }

    func openDocument(_ document: DocumentMetadata) {
        selectedDocumentID = document.id
        push(.documentDetail(id: document.id))
    }

    @MainActor func dataForDocument(id: UUID) -> Data? {
        documentStorage.data(for: id)
    }

    @discardableResult
    func generateDocument(using method: PDFGenerationMethod = .onDevice) async -> Bool {
        do {
            _ = try await DocumentGenerationService.shared.generateDocument(from: self, method: method)
            return true
        } catch {
#if DEBUG
            print("Failed to generate document: \(error.localizedDescription)")
#endif
            return false
        }
    }
}

struct SignUpData: Equatable {
    var email: String = ""
    var password: String = ""
    var fullName: String = ""
}

struct LogInData: Equatable {
    var email: String = ""
    var password: String = ""
}

struct PersonInfo {
    var fullName: String = ""
    var address: String = ""
    var email: String = ""
    var phone: String = ""
}

struct SpouseInfo {
    var name: String = ""
    var fullName: String = ""
    var email: String = ""
    var phone: String = ""
}

struct ChildInfo: Identifiable, Hashable {
    let id = UUID()
    var name: String = ""
    var dateOfBirth: String = ""
}

struct TrusteeInfo: Identifiable, Hashable {
    let id = UUID()
    var order: Int
    var fullName: String = ""
    var address: String = ""
    var phone: String = ""
    var email: String = ""
}
