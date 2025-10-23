import SwiftUI

@available(iOS 16.0, *)
struct ReferFriendView: View {
    @State private var friendEmail: String = ""
    @State private var showConfirmation = false

    var body: some View {
        DMFormScreen(title: "Refer to a Friend") {
            VStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.white)
                        .dmShadow()
                        .overlay(
                            VStack(spacing: 16) {
                                Image(systemName: "gift.fill")
                                    .font(.system(size: 56))
                                    .foregroundColor(.dmSecondary)

                                Text("Refer your friends and get up to 100 DocMaker Credits")
                                    .font(.headline)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.dmTextPrimary)

                                Text("Share your link. When a friend completes their trust, you both earn rewards.")
                                    .font(.footnote)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.dmTextSecondary)
                            }
                            .padding(24)
                        )
                }

                DMFormField("Friend's Email") {
                    TextField("name@email.com", text: $friendEmail)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }

                DMButton(title: "Send Invite", uppercase: false) {
                    showConfirmation = true
                }
                .disabled(friendEmail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .alert("Referral Sent", isPresented: $showConfirmation) {
                    Button("Done", role: .cancel) {
                        friendEmail = ""
                    }
                } message: {
                    Text("We emailed \(friendEmail) with your personal DocMaker referral link.")
                }
            }
        }
    }
}
