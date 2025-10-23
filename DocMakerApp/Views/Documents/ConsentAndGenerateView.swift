import SwiftUI

@available(iOS 16.0, *)
struct ConsentAndGenerateView: View {
    @EnvironmentObject private var appState: AppState
    @State private var showConfirmation = false

    var body: some View {
        DMFormScreen(title: "Legal Disclaimer") {
            VStack(alignment: .leading, spacing: 16) {
                Text("Start of Disclaimer")
                    .font(.headline)
                    .foregroundColor(.dmTextPrimary)

                Text("By locking your information you agree that all provided data is accurate and final. The generated PDFs will be prepared using the latest values stored in DocMaker and will become read-only once this step is complete.")
                    .foregroundColor(.dmTextSecondary)

                Text("End Disclaimer")
                    .font(.headline)
                    .foregroundColor(.dmTextPrimary)
            }

            DMButton(title: "+ Accept and Generate Docs") {
                showConfirmation = true
            }
            .alert("Confirm", isPresented: $showConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Lock & Generate", role: .destructive) {
                    appState.push(.generateDocs)
                }
            } message: {
                Text("Are you sure? 🔒 Once locked, the information cannot be edited and documents will be generated.")
            }

            DMButton(title: "+ Decline and Go Back", style: .secondary) {
                appState.pop()
            }
        }
    }
}
