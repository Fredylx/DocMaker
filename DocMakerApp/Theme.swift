import SwiftUI

extension Color {
    static let dmPrimary = Color(red: 0.0, green: 0.59, blue: 0.54)
    static let dmPrimaryDark = Color(red: 0.0, green: 0.47, blue: 0.43)
    static let dmSecondary = Color(red: 0.99, green: 0.75, blue: 0.20)
    static let dmBackground = Color(red: 0.94, green: 0.97, blue: 0.97)
    static let dmCardBackground = Color.white
    static let dmBorder = Color(red: 0.82, green: 0.90, blue: 0.91)
    static let dmTextPrimary = Color(red: 0.15, green: 0.24, blue: 0.27)
    static let dmTextSecondary = Color(red: 0.44, green: 0.57, blue: 0.59)
}

struct DMSpacing {
    static let stack: CGFloat = 16
    static let fieldSpacing: CGFloat = 12
}

struct DMShadow {
    static let card = Shadow(color: Color.black.opacity(0.08), radius: 20, x: 0, y: 10)

    struct Shadow {
        let color: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
    }
}

extension View {
    func dmCardBackground() -> some View {
        modifier(CardBackgroundModifier())
    }

    func dmShadow(_ shadow: DMShadow.Shadow = DMShadow.card) -> some View {
        self.shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }
}

private struct CardBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(24)
            .background(Color.dmCardBackground)
            .cornerRadius(24)
            .dmShadow()
    }
}
