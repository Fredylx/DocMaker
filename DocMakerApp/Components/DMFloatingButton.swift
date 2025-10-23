import SwiftUI

struct DMFloatingButton: View {
    let systemImage: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.title2)
                .foregroundColor(.white)
                .padding()
                .background(Color.dmSecondary)
                .clipShape(Circle())
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 6)
        }
        .buttonStyle(.plain)
    }
}
