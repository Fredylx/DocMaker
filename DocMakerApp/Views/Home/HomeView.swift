import SwiftUI

@available(iOS 16.0, *)
@available(iOS 16.0, *)
struct HomeView: View {
    @EnvironmentObject private var appState: AppState

    private var firstName: String {
        guard let name = appState.authenticatedUser?.fullName.split(separator: " ").first else {
            return "there"
        }
        return String(name)
    }

    private var getStartedActions: [HomeAction] {
        [
            HomeAction(title: "Quick Start", subtitle: "Create a new estate plan", icon: "bolt.fill", tint: .dmPrimary) {
                appState.push(.primaryPerson)
            },
            HomeAction(title: "Review Info", subtitle: "Verify personal details", icon: "checkmark.seal.fill", tint: Color(red: 0.22, green: 0.64, blue: 0.59)) {
                appState.push(.reviewInfo)
            },
            HomeAction(title: "Lock & Generate", subtitle: "Finalize and produce docs", icon: "lock.fill", tint: Color(red: 0.00, green: 0.45, blue: 0.43)) {
                appState.push(.legalConsent)
            },
            HomeAction(title: "View Documents", subtitle: "Access everything you've generated", icon: "doc.text.fill", tint: Color(red: 0.09, green: 0.36, blue: 0.62)) {
                appState.push(.documentsList)
            }
        ]
    }

    private var resourceActions: [HomeAction] {
        [
            HomeAction(title: "Ask AI", subtitle: "Get quick answers in plain English", icon: "sparkles", tint: Color(red: 0.55, green: 0.36, blue: 0.97)) {
                appState.push(.askAI)
            },
            HomeAction(title: "How it Works", subtitle: "Step-by-step walkthrough", icon: "list.bullet.rectangle.fill", tint: Color(red: 0.94, green: 0.60, blue: 0.20)) {
                appState.push(.howItWorks)
            },
            HomeAction(title: "FAQ", subtitle: "Answers to common questions", icon: "questionmark.circle.fill", tint: Color(red: 0.29, green: 0.49, blue: 0.57)) {
                appState.push(.faq)
            },
            HomeAction(title: "Refer & Earn", subtitle: "Share Doc Maker with friends", icon: "gift.fill", tint: Color(red: 0.94, green: 0.41, blue: 0.36)) {
                appState.push(.referFriend)
            }
        ]
    }

    private var supportActions: [HomeAction] {
        [
            HomeAction(title: "Buy", subtitle: "Unlock advanced features", icon: "creditcard.fill", tint: Color(red: 0.13, green: 0.24, blue: 0.33)) {
                appState.push(.payment)
            },
            HomeAction(title: "Contact Us", subtitle: "Talk with our support team", icon: "envelope.fill", tint: Color(red: 0.00, green: 0.48, blue: 0.73)) {
                appState.push(.contact)
            }
        ]
    }

    private var generatedDocumentCount: Int {
        appState.generatedDocuments.count
    }

    private var completedTrustees: Int {
        appState.trustees.filter { !$0.fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }.count
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            LinearGradient(colors: [Color.dmBackground, Color.white], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 32) {
                    HeroCard(firstName: firstName) {
                        appState.push(.primaryPerson)
                    } learnMoreAction: {
                        appState.push(.howItWorks)
                    }

                    InsightCard(documentCount: generatedDocumentCount, trusteeCount: completedTrustees)

                    HomeSection(title: "Get started", subtitle: "Everything you need to launch a new plan") {
                        HomeActionGrid(actions: getStartedActions)
                    }

                    HomeSection(title: "Resources", subtitle: "Guides, tools, and helpful explainers") {
                        HomeActionGrid(actions: resourceActions)
                    }

                    HomeSection(title: "Support", subtitle: "Upgrade or connect with our team") {
                        HomeActionGrid(actions: supportActions)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 140)
            }

            DMFloatingButton(systemImage: "bolt.fill") {
                appState.push(.primaryPerson)
            }
            .padding(24)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Text("Welcome, \(firstName)")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.dmTextSecondary)
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

// MARK: - Supporting Views

private struct HeroCard: View {
    let firstName: String
    var primaryAction: () -> Void
    var learnMoreAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Good to see you, \(firstName)")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.white)

                Text("You're only a few guided steps away from documents you can trust.")
                    .font(.callout)
                    .foregroundStyle(.white.opacity(0.9))
            }

            HStack(spacing: 16) {
                Button(action: primaryAction) {
                    Text("Start a document")
                        .font(.headline)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.white)
                        .foregroundColor(.dmPrimary)
                        .cornerRadius(14)
                }

                Button(action: learnMoreAction) {
                    Label("How it works", systemImage: "play.circle.fill")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.95))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(28)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [Color.dmPrimary, Color.dmPrimaryDark],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(32)
        .dmShadow()
    }
}

private struct InsightCard: View {
    let documentCount: Int
    let trusteeCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Your progress")
                .font(.headline)
                .foregroundColor(.dmTextPrimary)

            HStack(spacing: 16) {
                InsightItem(icon: "doc.on.doc.fill", title: "Generated docs", value: "\(documentCount)")

                InsightItem(icon: "person.2.fill", title: "Trustees added", value: "\(trusteeCount)")
            }
        }
        .padding(24)
        .background(Color.dmCardBackground)
        .cornerRadius(28)
        .dmShadow()
    }
}

private struct InsightItem: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.dmBackground)
                    .frame(width: 52, height: 52)

                Image(systemName: icon)
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.dmPrimary)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.dmTextPrimary)

                Text(title)
                    .font(.footnote)
                    .foregroundColor(.dmTextSecondary)
            }

            Spacer()
        }
        .padding(16)
        .background(Color.white.opacity(0.9))
        .cornerRadius(24)
    }
}

private struct HomeSection<Content: View>: View {
    let title: String
    var subtitle: String?
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title.uppercased())
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.dmTextSecondary)

                if let subtitle {
                    Text(subtitle)
                        .font(.title3.weight(.semibold))
                        .foregroundColor(.dmTextPrimary)
                }
            }

            content
        }
    }
}

private struct HomeActionGrid: View {
    let actions: [HomeAction]
    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(actions) { action in
                HomeActionTile(action: action)
            }
        }
    }
}

private struct HomeActionTile: View {
    let action: HomeAction

    var body: some View {
        Button(action: action.action) {
            VStack(alignment: .leading, spacing: 16) {
                ZStack {
                    Circle()
                        .fill(action.tint.opacity(0.15))
                        .frame(width: 46, height: 46)

                    Image(systemName: action.icon)
                        .font(.headline)
                        .foregroundColor(action.tint)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(action.title)
                        .font(.headline)
                        .foregroundColor(.dmTextPrimary)

                    if let subtitle = action.subtitle {
                        Text(subtitle)
                            .font(.footnote)
                            .foregroundColor(.dmTextSecondary)
                    }
                }

                Spacer(minLength: 0)

                HStack(spacing: 4) {
                    Text("Open")
                        .font(.footnote.weight(.semibold))
                        .foregroundColor(action.tint)

                    Image(systemName: "arrow.up.right")
                        .font(.footnote.weight(.semibold))
                        .foregroundColor(action.tint)
                }
            }
            .padding(18)
            .frame(maxWidth: .infinity, minHeight: 160, alignment: .topLeading)
            .background(Color.dmCardBackground)
            .cornerRadius(24)
            .dmShadow()
        }
        .buttonStyle(.plain)
    }
}

private struct HomeAction: Identifiable {
    let id = UUID()
    let title: String
    var subtitle: String?
    let icon: String
    let tint: Color
    let action: () -> Void
}
