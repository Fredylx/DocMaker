import SwiftUI

struct TrusteeInfoView: View {
    @EnvironmentObject private var appState: AppState
    let index: Int
    private let maxTrustees = 3

    var body: some View {
        DMFormScreen(title: "Person \(index + 1) Info") {
            let trustee = appState.trustee(at: index)

            DMFormField("Trustee \(index + 1) : Full Name") {
                TextField("Enter trustee \(index + 1) : full name...", text: binding(trustee, keyPath: \.fullName))
                    .textInputAutocapitalization(.words)
            }

            DMFormField("Trustee \(index + 1) : Address") {
                TextField("Enter trustee \(index + 1) : address...", text: binding(trustee, keyPath: \.address))
            }

            DMFormField("Trustee \(index + 1) : Phone") {
                TextField("Enter trustee \(index + 1) : phone number...", text: binding(trustee, keyPath: \.phone))
                    .keyboardType(.phonePad)
            }

            DMFormField("Trustee \(index + 1) : Email") {
                TextField("Enter trustee \(index + 1) : email...", text: binding(trustee, keyPath: \.email))
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }

            DMButton(title: primaryButtonTitle, uppercase: false) {
                primaryAction()
            }

            if shouldShowSecondaryButton {
                DMButton(title: secondaryButtonTitle, style: .secondary) {
                    secondaryAction()
                }
            }
        }
    }

    private var shouldShowSecondaryButton: Bool {
        if index == 0 {
            return appState.trustees.count < maxTrustees
        }
        return true
    }

    private var secondaryButtonTitle: String {
        if index == 0 {
            return "+ Add Person"
        }
        return "+ Delete Person"
    }

    private var primaryButtonTitle: String {
        if index >= maxTrustees - 1 {
            return "Generate Files"
        }
        return "Enter Person \(index + 2) Info"
    }

    private func primaryAction() {
        if index >= maxTrustees - 1 {
            appState.navigateToHome()
        } else {
            goToNextPerson()
        }
    }

    private func secondaryAction() {
        if index == 0 {
            let newIndex = appState.addTrustee()
            appState.push(.trustee(index: newIndex))
        } else {
            appState.removeTrustee(at: index)
            appState.pop()
        }
    }

    private func goToNextPerson() {
        let nextIndex = index + 1
        if nextIndex < appState.trustees.count {
            appState.push(.trustee(index: nextIndex))
        } else if nextIndex < maxTrustees {
            let createdIndex = appState.addTrustee()
            appState.push(.trustee(index: createdIndex))
        }
    }

    private func binding(_ trustee: Binding<TrusteeInfo>, keyPath: WritableKeyPath<TrusteeInfo, String>) -> Binding<String> {
        Binding<String>(
            get: { trustee.wrappedValue[keyPath: keyPath] },
            set: { trustee.wrappedValue[keyPath: keyPath] = $0 }
        )
    }
}
