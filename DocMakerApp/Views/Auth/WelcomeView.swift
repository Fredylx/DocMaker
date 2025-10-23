import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        ZStack {
            Color.dmBackground.ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer().frame(height: 24)

                Text("Doc Maker")
                    .font(.system(size: 42, weight: .bold))
                    .foregroundColor(.dmPrimary)

                VStack(spacing: 24) {
                    Image(systemName: "doc.richtext")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 180, height: 180)
                        .foregroundColor(.dmPrimary)
                        .padding(.top, 24)

                    DMButton(title: "Sign Up") {
                        appState.push(.signUp)
                    }

                    Button(action: {
                        appState.push(.logIn)
                    }) {
                        Text("Already have an account?")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.dmPrimary)
                    }
                    .buttonStyle(.plain)
                }
                .dmCardBackground()
                .padding(.horizontal, 32)

                Spacer()
            }
        }
    }
}
