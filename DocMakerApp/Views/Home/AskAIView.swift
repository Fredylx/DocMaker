import SwiftUI

@available(iOS 16.0, *)
struct AskAIView: View {
    @State private var prompt: String = ""
    @State private var showConfirmation = false

    private var trimmedPrompt: String {
        prompt.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        DMFormScreen(title: "Ask AI") {
            VStack(spacing: 20) {
                AIHeroCard()

                DMFormField("What would you like DocMaker AI to help with?", helperText: "Ask specific questions about your trust documents, updates, or legal terms.") {
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $prompt)
                            .frame(minHeight: 140, alignment: .topLeading)
                            .scrollContentBackground(.hidden)
                            .background(Color.clear)

                        if prompt.isEmpty {
                            Text("Type your question here…")
                                .foregroundColor(.dmTextSecondary)
                                .padding(.top, 8)
                                .padding(.horizontal, 4)
                        }
                    }
                }

                DMButton(title: "Send to DocMaker AI", uppercase: false) {
                    showConfirmation = true
                }
                .disabled(trimmedPrompt.isEmpty)
                .alert("We got your question!", isPresented: $showConfirmation) {
                    Button("Done", role: .cancel) {
                        prompt = ""
                    }
                } message: {
                    Text("A DocMaker specialist will review the following:")
                        + Text("\n\n\"")
                        + Text(prompt)
                        + Text("\"\n\nLook out for a response at the email tied to your account.")
                }

                Text("DocMaker AI summarizes complex trust language in plain English. It is not a substitute for personal legal advice.")
                    .font(.footnote)
                    .foregroundColor(.dmTextSecondary)
            }
        }
    }
}

@available(iOS 16.0, *)
private struct AIHeroCard: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 24)
            .fill(LinearGradient(colors: [Color.dmPrimary.opacity(0.85), Color.dmPrimaryDark], startPoint: .topLeading, endPoint: .bottomTrailing))
            .overlay(
                VStack(spacing: 16) {
                    Image(systemName: "brain.head.profile")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 96, height: 96)
                        .foregroundColor(Color.white)
                        .padding(8)
                        .background(Color.white.opacity(0.15))
                        .clipShape(Circle())

                    VStack(spacing: 8) {
                        Text("Meet DocMaker AI")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)

                        Text("Get quick answers about your estate plan and learn what every clause means for your family.")
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color.white.opacity(0.85))
                    }
                }
                .padding(28)
            )
            .dmShadow()
    }
}

