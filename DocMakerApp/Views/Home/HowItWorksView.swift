import SwiftUI

private struct HowItWorksStep: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
}

@available(iOS 16.0, *)
struct HowItWorksView: View {
    @Environment(\.openURL) private var openURL

    private let tutorialURL = URL(string: "https://www.youtube.com/watch?v=vdv8E5Fv050")!

    private let steps: [HowItWorksStep] = [
        HowItWorksStep(title: "Answer guided prompts", detail: "We translate plain-language questions into the legal clauses required for your revocable living trust."),
        HowItWorksStep(title: "Review and lock", detail: "Confirm beneficiaries, trustees, and guardians. Once everything looks right, lock your answers to generate final documents."),
        HowItWorksStep(title: "Download or print", detail: "Instantly access notarization-ready PDFs, along with a personalized checklist to finish signing.")
    ]

    var body: some View {
        DMFormScreen(title: "How it works") {
            VStack(spacing: 20) {
                HowItWorksVideoCard()

                VStack(alignment: .leading, spacing: 16) {
                    ForEach(steps) { step in
                        HowItWorksStepRow(step: step)
                    }
                }

                DMButton(title: "Watch full tutorial", style: .secondary, uppercase: false) {
                    openURL(tutorialURL)
                }

                Text("Need more help? Visit the FAQ or contact our support team for live assistance.")
                    .font(.footnote)
                    .foregroundColor(.dmTextSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

@available(iOS 16.0, *)
private struct HowItWorksVideoCard: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 24)
            .fill(Color.white)
            .overlay(
                VStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 18)
                            .fill(LinearGradient(colors: [Color.dmPrimary.opacity(0.15), Color.dmSecondary.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing))

                        Image(systemName: "play.rectangle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 160)
                            .foregroundColor(Color.dmPrimary)
                    }
                    .frame(height: 160)

                    VStack(spacing: 6) {
                        Text("See DocMaker in action")
                            .font(.headline)
                            .foregroundColor(.dmTextPrimary)

                        Text("This short video walks through selecting a template, filling guided fields, and generating your trust.")
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.dmTextSecondary)
                    }
                }
                .padding(24)
            )
            .dmShadow()
    }
}

@available(iOS 16.0, *)
private struct HowItWorksStepRow: View {
    let step: HowItWorksStep

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.dmPrimary)
                .font(.title3)
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 4) {
                Text(step.title)
                    .font(.headline)
                    .foregroundColor(.dmTextPrimary)

                Text(step.detail)
                    .font(.subheadline)
                    .foregroundColor(.dmTextSecondary)
            }
        }
        .padding(18)
        .background(Color.white)
        .cornerRadius(18)
        .dmShadow()
    }
}

