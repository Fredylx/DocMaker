import SwiftUI

@available(iOS 16.0, *)
struct ReviewInfoView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        DMFormScreen(title: "Review Info") {
            VStack(alignment: .leading, spacing: 12) {
                SummaryRow(title: "Customer Name", value: appState.primaryPerson.fullName)
                SummaryRow(title: "Address", value: appState.primaryPerson.address)
                SummaryRow(title: "Email", value: appState.primaryPerson.email)
                SummaryRow(title: "Phone", value: appState.primaryPerson.phone)

                Divider().padding(.vertical, 8)

                SummaryRow(title: "Spouse Name", value: appState.spouse.fullName)
                SummaryRow(title: "Spouse Email", value: appState.spouse.email)
                SummaryRow(title: "Spouse Phone", value: appState.spouse.phone)

                Divider().padding(.vertical, 8)

                if appState.children.filter({ !$0.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }).isEmpty {
                    SummaryRow(title: "Children", value: "No children information entered")
                } else {
                    ForEach(Array(appState.children.enumerated()), id: \.element.id) { index, child in
                        if !child.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            let dob = child.dateOfBirth.trimmingCharacters(in: .whitespacesAndNewlines)
                            let formattedDOB = dob.isEmpty ? "Not provided" : dob
                            SummaryRow(title: "Child #\(index + 1)", value: "\(child.name) – DOB: \(formattedDOB)")
                        }
                    }
                }

                Divider().padding(.vertical, 8)

                if appState.trustees.isEmpty {
                    SummaryRow(title: "Trustees", value: "No trustees captured")
                } else {
                    ForEach(appState.trustees) { trustee in
                        SummaryRow(title: "Trustee #\(trustee.order)", value: trusteeSummary(trustee))
                    }
                }
            }

            DMButton(title: "+ Lock Info and Generate Docs") {
                appState.push(.legalConsent)
            }
        }
    }

    private func trusteeSummary(_ trustee: TrusteeInfo) -> String {
        [
            trustee.fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : trustee.fullName,
            trustee.email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : trustee.email,
            trustee.phone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : trustee.phone
        ]
        .compactMap { $0 }
        .joined(separator: " \u2022 ")
        .ifEmpty("Incomplete trustee information")
    }
}

private struct SummaryRow: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title.uppercased())
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.dmTextSecondary)
            Text(value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Not provided" : value)
                .font(.body)
                .foregroundColor(.dmTextPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private extension String {
    func ifEmpty(_ fallback: String) -> String {
        trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? fallback : self
    }
}
