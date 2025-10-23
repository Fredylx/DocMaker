import SwiftUI

@available(iOS 16.0, *)
struct GeneratePDFView: View {
    @EnvironmentObject private var appState: AppState
    @State private var phase: GenerationPhase = .idle

    var body: some View {
        DMFormScreen(title: "Generate PDFs") {
            VStack(alignment: .leading, spacing: 16) {
                Text("Generate Docs step and process display tips show up.")
                    .foregroundColor(.dmTextSecondary)

                statusView
            }

            if phase == .success {
                DMButton(title: "+ Review Documents") {
                    appState.push(.documentsList)
                }
            } else if case .failure = phase {
                DMButton(title: "Retry Generation", style: .secondary) {
                    startGeneration(force: true)
                }
            }
        }
        .onAppear {
            startGeneration()
        }
    }

    @ViewBuilder
    private var statusView: some View {
        switch phase {
        case .idle, .generating:
            VStack(alignment: .leading, spacing: 12) {
                ProgressView()
                Text("We are preparing your trust documents. This may take a few seconds while PDFKit renders each section.")
                    .font(.footnote)
                    .foregroundColor(.dmTextSecondary)
            }
        case .success:
            VStack(alignment: .leading, spacing: 8) {
                Text("Documents have been generated.")
                    .font(.headline)
                    .foregroundColor(.dmTextPrimary)
                Text("Tap the button below to review, print, or share your new PDFs.")
                    .font(.footnote)
                    .foregroundColor(.dmTextSecondary)
            }
        case .failure(let message):
            VStack(alignment: .leading, spacing: 8) {
                Text("Generation failed")
                    .font(.headline)
                    .foregroundColor(.red)
                Text(message)
                    .font(.footnote)
                    .foregroundColor(.dmTextSecondary)
            }
        }
    }

    private func startGeneration(force: Bool = false) {
        guard force || phase == .idle else { return }
        phase = .generating

        Task {
            let success = await appState.generateDocument(using: PDFGenerationMethod.onDevice)
            await MainActor.run {
                if success {
                    phase = .success
                } else {
                    phase = .failure("We couldn't generate your PDFs. Please verify your connection or try the PDF.co renderer later.")
                }
            }
        }
    }

    private enum GenerationPhase: Equatable {
        case idle
        case generating
        case success
        case failure(String)
    }
}
