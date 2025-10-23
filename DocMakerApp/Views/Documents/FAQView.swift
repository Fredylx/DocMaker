import SwiftUI

private struct FAQItem: Identifiable, Hashable {
    let id = UUID()
    let question: String
    let answer: String
}

@available(iOS 16.0, *)
struct FAQView: View {
    private let items: [FAQItem] = [
        FAQItem(question: "How does DocMaker protect my trust?", answer: "Your data is encrypted on device and synced securely with iCloud when available. Only you can authorize document generation."),
        FAQItem(question: "Who can I assign as a trustee?", answer: "Any adult you trust can serve as a successor trustee. We recommend confirming availability before finalizing."),
        FAQItem(question: "Can I edit after locking?", answer: "You can always start a new revision. We keep the previous PDFs archived for compliance.")
    ]

    @State private var expandedItemIDs: Set<UUID> = []

    var body: some View {
        DMFormScreen(title: "FAQ") {
            VStack(spacing: 12) {
                ForEach(items) { item in
                    FAQCard(item: item, isExpanded: expandedItemIDs.contains(item.id))
                        .onTapGesture {
                            toggle(item)
                        }
                }
            }
        }
    }

    private func toggle(_ item: FAQItem) {
        if expandedItemIDs.contains(item.id) {
            expandedItemIDs.remove(item.id)
        } else {
            expandedItemIDs.insert(item.id)
        }
    }
}

private struct FAQCard: View {
    let item: FAQItem
    let isExpanded: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(item.question)
                    .font(.headline)
                    .foregroundColor(.dmTextPrimary)
                Spacer()
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .foregroundColor(.dmPrimary)
            }

            if isExpanded {
                Text(item.answer)
                    .font(.subheadline)
                    .foregroundColor(.dmTextSecondary)
            }
        }
        .padding(20)
        .background(Color.dmCardBackground)
        .cornerRadius(20)
        .dmShadow()
    }
}
