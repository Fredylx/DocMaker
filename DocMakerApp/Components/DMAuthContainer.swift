import SwiftUI

struct DMAuthContainer<Content: View>: View {
    let title: String
    let subtitle: String?
    @ViewBuilder var content: Content

    init(title: String, subtitle: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }

    var body: some View {
        ZStack {
            Color.dmBackground.ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer().frame(height: 16)

                VStack(spacing: 12) {
                    Text("Doc Maker")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.dmPrimary)

                    if let subtitle {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundColor(.dmTextSecondary)
                    }
                }

                VStack(spacing: 24) {
                    Text(title)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.dmPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 8)

                    content
                }
                .dmCardBackground()
                .padding(.horizontal, 32)

                Spacer()
            }
        }
    }
}
