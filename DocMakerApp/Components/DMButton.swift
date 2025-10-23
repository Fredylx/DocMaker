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
    var isEnabled: Bool = true
    var isLoading: Bool = false
    let action: () -> Void

    var body: some View {
        Button {
            guard isEnabled, !isLoading else { return }
            action()
        } label: {
            ZStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(foregroundColor)
                } else {
                    Text(uppercase ? title.uppercased() : title)
                        .font(.headline)
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .foregroundColor(foregroundColor)
            .background(background)
            .cornerRadius(14)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled || isLoading)
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
