import SwiftUI

struct DMHeaderBanner: View {
    var title: String
    var subtitle: String?
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        ZStack(alignment: .top) {
            LinearGradient(colors: [Color.dmPrimary, Color.dmPrimaryDark], startPoint: .topLeading, endPoint: .bottomTrailing)
                .frame(height: 200)
                .cornerRadius(28)
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(title.uppercased())
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    if let actionTitle, let action {
                        Button(action: action) {
                            Text(actionTitle.uppercased())
                                .font(.footnote)
                                .fontWeight(.semibold)
                                .padding(.vertical, 6)
                                .padding(.horizontal, 14)
                                .background(Color.white.opacity(0.2))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    }
                }

                if let subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                }

                Spacer()
            }
            .padding(24)
        }
    }
}
