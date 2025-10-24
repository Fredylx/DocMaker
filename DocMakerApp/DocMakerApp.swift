import SwiftUI
import GoogleSignIn
import UIKit

@available(iOS 16.0, *)
@main
struct DocMakerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

@available(iOS 16.0, *)
final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        if GoogleSignInConfig.isClientIDConfigured {
            GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: GoogleSignInConfig.clientID)
        }

        return true
    }

    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        GIDSignIn.sharedInstance.handle(url)
    }
}

@available(iOS 16.0, *)
private struct RootView: View {
    @StateObject private var appState = AppState()

    var body: some View {
        NavigationStack(path: $appState.path) {
            WelcomeView()
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .signUp:
                        SignUpView()
                    case .logIn:
                        LoginView()
                    case .home:
                        HomeView()
                    case .primaryPerson:
                        PrimaryPersonInfoView()
                    case .spouse:
                        SpouseInfoView()
                    case .children:
                        ChildrenInfoView()
                    case .trustee(let index):
                        TrusteeInfoView(index: index)
                    case .reviewInfo:
                        ReviewInfoView()
                    case .legalConsent:
                        ConsentAndGenerateView()
                    case .generateDocs:
                        GeneratePDFView()
                    case .documentsList:
                        DocumentListView()
                    case .documentDetail(let id):
                        DocumentDetailView(documentID: id)
                    case .payment:
                        PaymentTestModeView()
                    case .paymentSuccess:
                        PaymentSuccessView()
                    case .referFriend:
                        ReferFriendView()
                    case .contact:
                        ContactUsView()
                    case .faq:
                        FAQView()
                    case .askAI:
                        AskAIView()
                    case .howItWorks:
                        HowItWorksView()
                    }
                }
        }
        .environmentObject(appState)
    }
}
