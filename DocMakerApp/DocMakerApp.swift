import SwiftUI

@main
struct DocMakerApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

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
                    }
                }
        }
        .environmentObject(appState)
    }
}
