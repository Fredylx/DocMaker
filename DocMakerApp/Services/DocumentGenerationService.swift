import Foundation
import PDFKit

enum PDFGenerationMethod {
    case onDevice
    case pdfco
}

@available(iOS 16.0, *)
@MainActor
final class DocumentGenerationService {
    static let shared = DocumentGenerationService()

    private let pdfcoClient: PDFcoClient

    private init(pdfcoClient: PDFcoClient = PDFcoClient()) {
        self.pdfcoClient = pdfcoClient
    }

    func generateDocument(from state: AppState, method: PDFGenerationMethod = .onDevice) async throws -> DocumentMetadata {
        let sections = buildSections(from: state)
        let title = makeDocumentTitle()
        let data: Data

        switch method {
        case .onDevice:
            data = try PDFComposer.makePDF(title: title, sections: sections)
        case .pdfco:
            let html = makeHTML(from: title, sections: sections)
            do {
                data = try await pdfcoClient.generatePDF(html: html)
            } catch {
#if DEBUG
                print("PDF.co generation failed, falling back to on-device renderer: \(error.localizedDescription)")
#endif
                data = try PDFComposer.makePDF(title: title, sections: sections)
            }
        }

        return try await DocumentStorage.shared.storeDocument(data: data, title: title)
    }

    private func makeDocumentTitle() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return "Living Trust Packet – \(formatter.string(from: Date()))"
    }

    private func makeHTML(from title: String, sections: [String]) -> String {
        let body = sections.map { "<p>\($0)</p>" }.joined(separator: "")
        return "<html><head><meta charset=\"utf-8\"><style>body{font-family:-apple-system;font-size:14px;color:#1b2a2f;padding:48px;}h1{font-size:24px;}p{line-height:1.5;margin-bottom:12px;color:#49666a;}</style></head><body><h1>\(title)</h1>\(body)</body></html>"
    }

    private func buildSections(from state: AppState) -> [String] {
        var sections: [String] = []

        let primary = state.primaryPerson
        sections.append("Customer Name: \(display(primary.fullName))")
        sections.append("Address: \(display(primary.address))")
        sections.append("Email: \(display(primary.email))")
        sections.append("Phone: \(display(primary.phone))")

        let spouse = state.spouse
        sections.append("Spouse Name: \(display(spouse.fullName))")
        sections.append("Spouse Email: \(display(spouse.email))")
        sections.append("Spouse Phone: \(display(spouse.phone))")

        let nonEmptyChildren = state.children.filter { !$0.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        if nonEmptyChildren.isEmpty {
            sections.append("Children: No children entered")
        } else {
            for child in nonEmptyChildren {
                sections.append("Child – \(child.name) (DOB: \(display(child.dateOfBirth)))")
            }
        }

        if state.trustees.isEmpty {
            sections.append("Trustees: Pending")
        } else {
            for trustee in state.trustees {
                sections.append("Trustee #\(trustee.order): \(display(trustee.fullName)) – Email: \(display(trustee.email)) – Phone: \(display(trustee.phone))")
            }
        }

        sections.append("Generated: \(DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .short))")

        return sections
    }

    private func display(_ value: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Not provided" : trimmed
    }
}
