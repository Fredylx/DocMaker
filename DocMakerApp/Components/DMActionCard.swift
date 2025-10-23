import SwiftUI

struct DMActionCard: View {
    let title: String
    var description: String?
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Label {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.headline)
                        if let description {
                            Text(description)
                                .font(.footnote)
                                .foregroundColor(.dmTextSecondary)
                        }
                    }
                } icon: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                }
                .labelStyle(.leadingIcon)

                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(18)
            .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
            .foregroundColor(.dmPrimary)
        }
        .buttonStyle(.plain)
    }
}

private struct LeadingIconLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .center, spacing: 12) {
            configuration.icon
            configuration.title
        }
    }
}

extension LabelStyle where Self == LeadingIconLabelStyle {
    static var leadingIcon: LeadingIconLabelStyle { LeadingIconLabelStyle() }
}
