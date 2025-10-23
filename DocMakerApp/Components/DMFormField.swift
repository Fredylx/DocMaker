import SwiftUI

struct DMFormField<Content: View>: View {
    let title: String
    let helperText: String?
    @ViewBuilder var content: Content

    init(_ title: String, helperText: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.helperText = helperText
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.footnote)
                .fontWeight(.semibold)
                .foregroundColor(.dmTextSecondary)

            content
                .padding(.vertical, 12)
                .padding(.horizontal, 14)
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.dmBorder, lineWidth: 1)
                )

            if let helper = helperText {
                Text(helper)
                    .font(.caption)
                    .foregroundColor(.dmTextSecondary)
            }
        }
    }
}
