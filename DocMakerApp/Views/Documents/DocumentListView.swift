import SwiftUI

@available(iOS 16.0, *)
struct DocumentListView: View {
    @EnvironmentObject private var appState: AppState

    private let columns = [GridItem(.adaptive(minimum: 140), spacing: 16)]

    var body: some View {
        DMFormScreen(title: "Documents List") {
            if appState.generatedDocuments.isEmpty {
                EmptyStateView()
            } else {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(appState.generatedDocuments) { document in
                        Button {
                            appState.openDocument(document)
                        } label: {
                            DocumentCard(document: document)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            DMButton(title: "+ Payment", style: .secondary) {
                appState.push(.payment)
            }
        }
    }
}

private struct DocumentCard: View {
    let document: DocumentMetadata

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.dmPrimary.opacity(0.08))
                    .frame(height: 140)
                    .overlay(
                        Image(systemName: "doc.richtext")
                            .font(.system(size: 44))
                            .foregroundColor(.dmPrimary)
                    )
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(document.title)
                    .font(.headline)
                    .foregroundColor(.dmTextPrimary)
                    .lineLimit(2)

                Text("Created \(document.formattedDate)")
                    .font(.caption)
                    .foregroundColor(.dmTextSecondary)

                HStack {
                    Text(document.formattedSize)
                        .font(.caption)
                        .foregroundColor(.dmTextSecondary)
                    Spacer()
                    Text(document.cloudStatusDescription)
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(document.cloudRecordName == nil ? .orange : .dmPrimary)
                }
            }
        }
        .padding(16)
        .background(Color.dmCardBackground)
        .cornerRadius(20)
        .dmShadow()
    }
}

private struct EmptyStateView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("No documents yet")
                .font(.headline)
                .foregroundColor(.dmTextPrimary)
            Text("Once you lock your information and complete generation, your PDFs will appear here for review and sharing.")
                .font(.footnote)
                .foregroundColor(.dmTextSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.dmCardBackground)
        .cornerRadius(16)
        .dmShadow()
    }
}
