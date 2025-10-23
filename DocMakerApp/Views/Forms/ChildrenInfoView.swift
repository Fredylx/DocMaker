import SwiftUI

@available(iOS 16.0, *)
@available(iOS 16.0, *)
struct ChildrenInfoView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        DMFormScreen(title: "Children Info") {
            ForEach(childIndices, id: \.self) { index in
                DMFormField("Child \(index + 1) Full Name") {
                    TextField("Enter child \(index + 1) full name...", text: binding(for: \.name, at: index))
                        .textInputAutocapitalization(.words)
                }

                DMFormField("Date of Birth") {
                    TextField("Enter child \(index + 1) date of birth...", text: binding(for: \.dateOfBirth, at: index))
                }
            }

            DMButton(title: "Create Child") {
                appState.startTrusteeFlow()
            }

            DMButton(title: "+ Delete Child Info", style: .secondary) {
                appState.clearChildren()
            }
        }
    }

    private var childIndices: [Int] {
        Array(appState.children.indices)
    }

    private func binding(for keyPath: WritableKeyPath<ChildInfo, String>, at index: Int) -> Binding<String> {
        Binding<String>(
            get: {
                guard appState.children.indices.contains(index) else { return "" }
                return appState.children[index][keyPath: keyPath]
            },
            set: { newValue in
                guard appState.children.indices.contains(index) else { return }
                appState.children[index][keyPath: keyPath] = newValue
            }
        )
    }
}
