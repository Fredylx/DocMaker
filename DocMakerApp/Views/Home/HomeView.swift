import SwiftUI

@available(iOS 16.0, *)
struct HomeView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            LinearGradient(colors: [Color.dmBackground, Color.white], startPoint: .topLeading, endPoint: .bottomTrailing)
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
                            .foregroundColor(.dmTextSecondary)

                        Text(user.fullName.components(separatedBy: " ").first ?? user.fullName)
                            .font(.headline)
                            .foregroundColor(.dmTextPrimary)
                    }
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    appState.signOut()
                } label: {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .imageScale(.medium)
                        .foregroundColor(.dmPrimary)
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 4)
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
                        .foregroundColor(.white.opacity(0.9))

                    Text("Let’s complete your estate plan with confidence.")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                Image(systemName: "shield.checkerboard")
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundColor(.white.opacity(0.7))
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color.white.opacity(0.15))
                    )
            }

            HStack(spacing: 16) {
                HeroStatView(icon: "doc.text", title: "\(appState.generatedDocuments.count)", subtitle: "Documents ready")

                HeroStatView(icon: "checkmark.circle", title: "\(completionPercentage)%", subtitle: "Profile complete")
            }

            HStack(spacing: 12) {
                Button {
                    appState.push(.primaryPerson)
                } label: {
                    Label("Start new document", systemImage: "sparkles")
                        .font(.subheadline.weight(.semibold))
                        .padding(.vertical, 12)
                        .padding(.horizontal, 20)
                        .background(Color.white)
                        .foregroundColor(Color.dmPrimary)
                        .cornerRadius(18)
                }
                .buttonStyle(.plain)

                Button {
                    appState.push(.payment)
                } label: {
                    Label("View plans", systemImage: "crown")
                        .font(.footnote.weight(.semibold))
                        .padding(.vertical, 10)
                        .padding(.horizontal, 18)
                        .background(Color.white.opacity(0.18))
                        .foregroundColor(.white)
                        .cornerRadius(16)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(26)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(
                    LinearGradient(colors: [Color.dmPrimary, Color.dmPrimaryDark.opacity(0.95)], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .overlay(
                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.15), lineWidth: 1)
                            .frame(width: 200, height: 200)
                            .offset(x: 120, y: -100)

                        Circle()
                            .fill(Color.white.opacity(0.08))
                            .frame(width: 140, height: 140)
                            .offset(x: -140, y: 80)
                    }
                )
        )
        .shadow(color: Color.dmPrimary.opacity(0.22), radius: 22, x: 0, y: 16)
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

    var completionPercentage: Int {
        let total = Double(profileCompletionStates.count)
        guard total > 0 else { return 0 }

        let completed = Double(profileCompletionStates.filter { $0 }.count)
        return Int((completed / total * 100).rounded())
    }

    var profileCompletionStates: [Bool] {
        [
            !appState.primaryPerson.fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
            !(appState.spouse.fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
              appState.spouse.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty),
            appState.children.contains { !$0.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty },
            appState.trustees.contains { !$0.fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        ]
    }

    func sectionHeader(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.title3.weight(.semibold))
                .foregroundColor(.dmTextPrimary)

            Text(subtitle)
                .font(.footnote)
                .foregroundColor(.dmTextSecondary)
        }
    }
}

private extension HomeView {
    struct HeroStatView: View {
        let icon: String
        let title: String
        let subtitle: String

        var body: some View {
            HStack(alignment: .center, spacing: 12) {
                Image(systemName: icon)
                    .font(.title3.weight(.semibold))
                    .frame(width: 42, height: 42)
                    .background(Color.white.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.title3.weight(.bold))
                        .foregroundColor(.white)

                    Text(subtitle)
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(Color.white.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
    }

    struct HomeActionCard: View {
        let action: HomeAction

        var body: some View {
            Button(action: action.perform) {
                VStack(alignment: .leading, spacing: 18) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(action.tint.opacity(0.18))
                            .frame(width: 54, height: 54)

                        Image(systemName: action.icon)
                            .font(.title3.weight(.semibold))
                            .foregroundColor(action.tint)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text(action.title)
                            .font(.headline)
                            .foregroundColor(.dmTextPrimary)

                        Text(action.subtitle)
                            .font(.footnote)
                            .foregroundColor(.dmTextSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(20)
                .frame(maxWidth: .infinity, minHeight: 160, alignment: .topLeading)
                .background(
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.08), radius: 16, x: 0, y: 12)
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
                        .foregroundColor(.dmPrimary)
                        .frame(width: 44, height: 44)
                        .background(Color.dmPrimary.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                    VStack(alignment: .leading, spacing: 6) {
                        Text(item.title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.dmTextPrimary)

                        Text(item.subtitle)
                            .font(.footnote)
                            .foregroundColor(.dmTextSecondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.semibold))
                        .foregroundColor(.dmBorder)
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .stroke(Color.dmBorder.opacity(0.35), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 8)
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
