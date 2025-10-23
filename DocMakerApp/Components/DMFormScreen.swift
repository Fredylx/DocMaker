import SwiftUI
import UIKit

struct DMFormScreen<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color.dmBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                LinearGradient(colors: [Color.dmPrimary, Color.dmPrimaryDark], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .frame(height: 160)
                    .overlay(alignment: .leading) {
                        Text(title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.bottom, 24)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .clipShape(RoundedCorner(radius: 32, corners: [.bottomLeft, .bottomRight]))

                Spacer()
            }

            ScrollView {
                VStack(alignment: .leading, spacing: DMSpacing.stack) {
                    content
                }
                .padding(24)
                .padding(.top, 140)
            }
        }
    }
}

private struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
