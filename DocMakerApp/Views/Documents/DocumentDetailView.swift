import SwiftUI
import PDFKit
import UIKit

@available(iOS 16.0, *)
struct DocumentDetailView: View {
    @EnvironmentObject private var appState: AppState

    let documentID: UUID
    @State private var pdfData: Data?
    @State private var loadError: String?

    private var document: DocumentMetadata? {
        appState.generatedDocuments.first(where: { $0.id == documentID })
    }

    var body: some View {
        DMFormScreen(title: document?.title ?? "Document Viewer") {
            if let data = pdfData {
                PDFKitView(data: data)
                    .frame(maxHeight: 480)
                    .cornerRadius(18)
                    .dmShadow()
            } else if let loadError {
                Text(loadError)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                ProgressView("Loading document…")
            }

            if let document {
                Text("Generated on \(document.formattedDate) · \(document.formattedSize)")
                    .font(.footnote)
                    .foregroundColor(.dmTextSecondary)
            }

            DMButton(title: "+ Save or Print") {
                shareDocument()
            }
            .disabled(pdfData == nil)
        }
        .onAppear(perform: loadDocument)
    }

    private func loadDocument() {
        pdfData = appState.dataForDocument(id: documentID)
        if pdfData == nil {
            loadError = "Unable to load the PDF data."
        }
    }

    private func shareDocument() {
        guard let data = pdfData else { return }
        let temporaryURL = FileManager.default.temporaryDirectory.appendingPathComponent("document-\(documentID).pdf")
        do {
            try data.write(to: temporaryURL, options: .atomic)
            let activityController = UIActivityViewController(activityItems: [temporaryURL], applicationActivities: nil)
            UIApplication.shared.present(activityController, animated: true)
        } catch {
#if DEBUG
            print("Failed to share PDF: \(error.localizedDescription)")
#endif
        }
    }
}

@available(iOS 16.0, *)
private struct PDFKitView: UIViewRepresentable {
    let data: Data

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayDirection = .vertical
        pdfView.displayMode = .singlePageContinuous
        pdfView.backgroundColor = .clear
        return pdfView
    }

    func updateUIView(_ pdfView: PDFView, context: Context) {
        pdfView.document = PDFDocument(data: data)
    }
}

private extension UIApplication {
    func present(_ controller: UIViewController, animated: Bool) {
        guard let scene = connectedScenes.compactMap({ $0 as? UIWindowScene }).first,
              let root = scene.windows.first(where: { $0.isKeyWindow })?.rootViewController else { return }

        var topController = root
        while let presented = topController.presentedViewController {
            topController = presented
        }

        topController.present(controller, animated: animated, completion: nil)
    }
}
