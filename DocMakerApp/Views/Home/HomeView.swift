import SwiftUI

@available(iOS 16.0, *)
struct HomeView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            LinearGradient(colors: [HomePalette.backgroundTop, HomePalette.backgroundBottom], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 32) {
                    heroCard

                    quickActionsSection

                    resourcesSection
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 28)
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
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Welcome back,")
                            .font(.caption)
                            .foregroundColor(HomePalette.textSecondary)

                        Text(user.fullName.components(separatedBy: " ").first ?? user.fullName)
                            .font(.headline)
                            .foregroundColor(HomePalette.textPrimary)
                    }
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    appState.signOut()
                } label: {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .imageScale(.medium)
                        .foregroundColor(HomePalette.accent)
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 6)
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Sign Out")
            }
        }
    }
}

private extension HomeView {
    var heroCard: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack(alignment: .top, spacing: 20) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(greeting)
                        .font(.title3.weight(.semibold))
                        .foregroundColor(HomePalette.textPrimary)

                    Text("Let’s complete your estate plan with confidence.")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(HomePalette.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("Pick up where you left off or explore new guidance tailored for you.")
                        .font(.subheadline)
                        .foregroundColor(HomePalette.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                Image(systemName: "shield.checkerboard")
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundColor(HomePalette.accent)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(HomePalette.badgeBackground)
                    )
            }

            Button {
                appState.push(.documentsList)
            } label: {
                Label("Go to my documents", systemImage: "doc.text")
                    .font(.subheadline.weight(.semibold))
                    .padding(.vertical, 12)
                    .padding(.horizontal, 20)
                    .background(Color.white)
                    .foregroundColor(HomePalette.accent)
                    .cornerRadius(18)
                    .shadow(color: HomePalette.cardShadow, radius: 12, x: 0, y: 6)
            }
            .buttonStyle(.plain)

            Button {
                appState.push(.payment)
            } label: {
                Label("Explore plans", systemImage: "crown")
                    .font(.footnote.weight(.semibold))
                    .padding(.vertical, 10)
                    .padding(.horizontal, 18)
                    .background(HomePalette.accent.opacity(0.1))
                    .foregroundColor(HomePalette.accent)
                    .cornerRadius(16)
            }
            .buttonStyle(.plain)
        }
        .padding(26)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(
                    LinearGradient(colors: [HomePalette.heroTop, HomePalette.heroBottom], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .overlay(
                    ZStack {
                        Circle()
                            .stroke(HomePalette.heroHighlight.opacity(0.4), lineWidth: 1)
                            .frame(width: 200, height: 200)
                            .offset(x: 120, y: -100)

                        Circle()
                            .fill(HomePalette.heroHighlight.opacity(0.25))
                            .frame(width: 140, height: 140)
                            .offset(x: -140, y: 80)
                    }
                )
        )
        .shadow(color: HomePalette.heroShadow, radius: 22, x: 0, y: 16)
    }

    var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(title: "Quick actions", subtitle: "Jump right back into your workflow")

            LazyVGrid(columns: quickGridColumns, spacing: 16) {
                ForEach(quickActions) { action in
                    HomeActionCard(action: action)
                }
            }
        }
    }

    var resourcesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(title: "Guided resources", subtitle: "Everything you need for peace of mind")

            VStack(spacing: 12) {
                ForEach(resourceActions) { item in
                    HomeListRow(item: item)
                }
            }
        }
    }

    var quickGridColumns: [GridItem] {
        [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)]
    }

    var quickActions: [HomeAction] {
        [
            HomeAction(
                title: "Quick Start",
                subtitle: "Begin a fresh document.",
                icon: "sparkles",
                tint: Color.dmPrimary
            ) {
                appState.push(.primaryPerson)
            },
            HomeAction(
                title: "Review Info",
                subtitle: "Verify your family details.",
                icon: "list.clipboard",
                tint: Color.dmSecondary
            ) {
                appState.push(.reviewInfo)
            },
            HomeAction(
                title: "Lock & Generate",
                subtitle: "Finalize and create docs.",
                icon: "lock.shield",
                tint: Color.dmPrimaryDark
            ) {
                appState.push(.legalConsent)
            },
            HomeAction(
                title: "My Documents",
                subtitle: "Review what you've created.",
                icon: "doc.richtext",
                tint: Color.dmTextPrimary
            ) {
                appState.push(.documentsList)
            }
        ]
    }

    var resourceActions: [HomeListItem] {
        [
            HomeListItem(
                title: "Upgrade to Premium",
                subtitle: "Unlock unlimited document generations.",
                icon: "crown.fill"
            ) {
                appState.push(.payment)
            },
            HomeListItem(
                title: "Ask Doc Maker AI",
                subtitle: "Get quick answers any time.",
                icon: "sparkle.magnifyingglass"
            ) {
                appState.push(.askAI)
            },
            HomeListItem(
                title: "How it works",
                subtitle: "Step-by-step walkthrough of the process.",
                icon: "play.rectangle"
            ) {
                appState.push(.howItWorks)
            },
            HomeListItem(
                title: "FAQs",
                subtitle: "Browse the most common questions.",
                icon: "questionmark.circle"
            ) {
                appState.push(.faq)
            },
            HomeListItem(
                title: "Refer & earn",
                subtitle: "Share Doc Maker with friends and family.",
                icon: "gift"
            ) {
                appState.push(.referFriend)
            },
            HomeListItem(
                title: "Contact support",
                subtitle: "Reach out to our estate experts.",
                icon: "envelope"
            ) {
                appState.push(.contact)
            }
        ]
    }

    var greeting: String {
        if let user = appState.authenticatedUser {
            let firstName = user.fullName.components(separatedBy: " ").first ?? user.fullName
            return "Hi, \(firstName)!"
        }

        return "Welcome to Doc Maker"
    }

    func sectionHeader(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.title3.weight(.semibold))
                .foregroundColor(HomePalette.textPrimary)

            Text(subtitle)
                .font(.footnote)
                .foregroundColor(HomePalette.textSecondary)
        }
    }
}

private extension HomeView {
    struct HomeActionCard: View {
        let action: HomeAction

        var body: some View {
            Button(action: action.perform) {
                VStack(alignment: .leading, spacing: 18) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(action.tint.opacity(0.15))
                            .frame(width: 54, height: 54)

                        Image(systemName: action.icon)
                            .font(.title3.weight(.semibold))
                            .foregroundColor(action.tint)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text(action.title)
                            .font(.headline)
                            .foregroundColor(HomePalette.textPrimary)

                        Text(action.subtitle)
                            .font(.footnote)
                            .foregroundColor(HomePalette.textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(20)
                .frame(maxWidth: .infinity, minHeight: 160, alignment: .topLeading)
                .background(
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .fill(Color.white)
                        .shadow(color: HomePalette.cardShadow, radius: 18, x: 0, y: 12)
                )
            }
            .buttonStyle(.plain)
        }
    }

    struct HomeListRow: View {
        let item: HomeListItem

        var body: some View {
            Button(action: item.perform) {
                HStack(alignment: .center, spacing: 16) {
                    Image(systemName: item.icon)
                        .font(.title3.weight(.semibold))
                        .foregroundColor(HomePalette.accent)
                        .frame(width: 44, height: 44)
                        .background(HomePalette.badgeBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                    VStack(alignment: .leading, spacing: 6) {
                        Text(item.title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(HomePalette.textPrimary)

                        Text(item.subtitle)
                            .font(.footnote)
                            .foregroundColor(HomePalette.textSecondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.semibold))
                        .foregroundColor(HomePalette.textSecondary)
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color.white)
                        .shadow(color: HomePalette.cardShadow, radius: 16, x: 0, y: 10)
                )
            }
            .buttonStyle(.plain)
        }
    }

    struct HomeAction: Identifiable {
        let title: String
        let subtitle: String
        let icon: String
        let tint: Color
        let perform: () -> Void

        var id: String { title }
    }

    struct HomeListItem: Identifiable {
        let title: String
        let subtitle: String
        let icon: String
        let perform: () -> Void

        var id: String { title }
    }
}

private extension HomeView {
    enum HomePalette {
        static let backgroundTop = Color(red: 0.96, green: 0.98, blue: 1.0)
        static let backgroundBottom = Color.white
        static let heroTop = Color(red: 0.86, green: 0.92, blue: 1.0)
        static let heroBottom = Color(red: 0.69, green: 0.83, blue: 1.0)
        static let heroHighlight = Color.white
        static let heroShadow = Color(red: 0.55, green: 0.68, blue: 0.96).opacity(0.25)
        static let badgeBackground = Color.white.opacity(0.7)
        static let cardShadow = Color.black.opacity(0.08)
        static let textPrimary = Color.dmTextPrimary
        static let textSecondary = Color.dmTextSecondary
        static let accent = Color.dmPrimary
    }
}
