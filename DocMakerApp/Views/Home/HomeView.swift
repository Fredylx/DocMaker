import SwiftUI

@available(iOS 16.0, *)
@available(iOS 16.0, *)
struct HomeView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color.dmBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    DMHeaderBanner(title: "Doc Maker", subtitle: "Launch a new document or pick up where you left off", actionTitle: "+ Buy") {
                        // Placeholder for purchase flow
                    }

                    VStack(spacing: 16) {
                        DMActionCard(title: "+ Quick Start") {
                            appState.push(.primaryPerson)
                        }

                        DMActionCard(title: "+ Review Info") {
                            appState.push(.reviewInfo)
                        }

                        DMActionCard(title: "+ Lock Info & Generate Docs") {
                            appState.push(.legalConsent)
                        }

                        DMActionCard(title: "+ View Documents") {
                            appState.push(.documentsList)
                        }

                        DMActionCard(title: "+ FAQ") {
                            appState.push(.faq)
                        }

                        DMActionCard(title: "+ Ask AI") {
                            appState.push(.askAI)
                        }

                        DMActionCard(title: "+ Explain how it works") {
                            appState.push(.howItWorks)
                        }

                        DMActionCard(title: "+ Buy") {
                            appState.push(.payment)
                        }

                        DMActionCard(title: "+ Refer and Earn") {
                            appState.push(.referFriend)
                        }

                        DMActionCard(title: "+ Contact Us") {
                            appState.push(.contact)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 80)
            }

            DMFloatingButton(systemImage: "plus") {
                appState.push(.primaryPerson)
            }
            .padding(24)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                if let user = appState.authenticatedUser {
                    Text("Hello, \(user.fullName.components(separatedBy: " ").first ?? user.fullName)!")
                        .font(.subheadline)
                        .foregroundColor(.dmTextSecondary)
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    appState.signOut()
                } label: {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .imageScale(.medium)
                        .foregroundColor(.dmPrimary)
                }
                .accessibilityLabel("Sign Out")
            }
        }
    }
}
