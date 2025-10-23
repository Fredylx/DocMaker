import SwiftUI

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
                            appState.push(.children)
                        }

                        DMActionCard(title: "+ Lock Info & Generate Docs") {
                            appState.startTrusteeFlow()
                        }

                        DMActionCard(title: "+ View Documents") {
                            // Placeholder
                        }

                        DMActionCard(title: "+ FAQ") {
                            // Placeholder
                        }

                        DMActionCard(title: "+ Explain how it works") {
                            // Placeholder
                        }

                        DMActionCard(title: "+ Buy") {
                            // Placeholder
                        }

                        DMActionCard(title: "+ Refer and Earn") {
                            // Placeholder
                        }

                        DMActionCard(title: "+ Contact Us") {
                            // Placeholder
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
    }
}
