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
}

@available(iOS 16.0, *)
@MainActor
final class AppState: ObservableObject {
    @Published var path = NavigationPath()

    @Published var signUpData = SignUpData()
    @Published var logInData = LogInData()
    @Published var primaryPerson = PersonInfo()
    @Published var spouse = SpouseInfo()
    @Published var children: [ChildInfo] = [ChildInfo(), ChildInfo(), ChildInfo()]
    @Published private(set) var trustees: [TrusteeInfo] = [TrusteeInfo(order: 1)]
    @Published private(set) var generatedDocuments: [DocumentMetadata] = []
    @Published var selectedDocumentID: UUID?

    private var cancellables = Set<AnyCancellable>()
    private let documentStorage: DocumentStorage

    init(documentStorage: DocumentStorage = .shared) {
        self.documentStorage = documentStorage
        self.generatedDocuments = documentStorage.documents

        documentStorage.$documents
            .receive(on: DispatchQueue.main)
            .sink { [weak self] documents in
                self?.generatedDocuments = documents
            }
            .store(in: &cancellables)
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
        logInData = LogInData()
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

struct SignUpData {
    var email: String = ""
    var password: String = ""
    var fullName: String = ""
}

struct LogInData {
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
