import SwiftUI

enum DMButtonStyleType {
    case primary
    case secondary
    case text
}

struct DMButton: View {
    let title: String
    var style: DMButtonStyleType = .primary
    var uppercase: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(uppercase ? title.uppercased() : title)
                .font(.headline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .foregroundColor(foregroundColor)
                .background(background)
                .cornerRadius(14)
        }
        .buttonStyle(.plain)
        .dmShadow(style == .text ? DMShadow.Shadow(color: .clear, radius: 0, x: 0, y: 0) : DMShadow.card)
    }

    private var background: some View {
        Group {
            switch style {
            case .primary:
                Color.dmSecondary
            case .secondary:
                Color.dmPrimary
            case .text:
                Color.clear
            }
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .primary:
            return Color.white
        case .secondary:
            return Color.white
        case .text:
            return Color.dmPrimary
        }
    }
}
