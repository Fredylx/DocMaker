import Foundation
import UIKit
import PDFKit

enum PDFComposerError: Error {
    case unableToRender
}

struct PDFComposer {
    static func makePDF(title: String, sections: [String]) throws -> Data {
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        let data = renderer.pdfData { context in
            context.beginPage()

            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 24, weight: .semibold),
                .foregroundColor: UIColor.label
            ]

            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 6
            paragraphStyle.paragraphSpacing = 12

            let bodyAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14),
                .paragraphStyle: paragraphStyle,
                .foregroundColor: UIColor.secondaryLabel
            ]

            var currentOrigin = CGPoint(x: 48, y: 72)
            let titleHeight = title.boundingRect(with: CGSize(width: pageRect.width - 96, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: titleAttributes, context: nil).height
            title.draw(in: CGRect(x: currentOrigin.x, y: currentOrigin.y, width: pageRect.width - 96, height: titleHeight), withAttributes: titleAttributes)
            currentOrigin.y += titleHeight + 24

            for section in sections {
                let attributed = NSAttributedString(string: section + "\n", attributes: bodyAttributes)
                let bounding = attributed.boundingRect(with: CGSize(width: pageRect.width - 96, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)

                if currentOrigin.y + bounding.height > pageRect.height - 72 {
                    context.beginPage()
                    currentOrigin = CGPoint(x: 48, y: 72)
                }

                attributed.draw(in: CGRect(x: currentOrigin.x, y: currentOrigin.y, width: pageRect.width - 96, height: bounding.height))
                currentOrigin.y += bounding.height
            }
        }

        guard !data.isEmpty else { throw PDFComposerError.unableToRender }
        return data
    }
}
