import Foundation

enum PDFcoClientError: Error, LocalizedError {
    case invalidConfiguration
    case invalidResponse
    case requestFailed(Int)

    var errorDescription: String? {
        switch self {
        case .invalidConfiguration:
            return "PDF.co API key is not configured."
        case .invalidResponse:
            return "The PDF.co response could not be parsed."
        case .requestFailed(let code):
            return "PDF.co request failed with status code \(code)."
        }
    }
}

struct PDFcoClient {
    var apiKey: String? = ProcessInfo.processInfo.environment["PDFCO_API_KEY"]
    var session: URLSession = .shared

    func generatePDF(html: String) async throws -> Data {
        guard let apiKey = apiKey, !apiKey.isEmpty else {
            throw PDFcoClientError.invalidConfiguration
        }

        guard let url = URL(string: "https://api.pdf.co/v1/pdf/convert/from/html") else {
            throw PDFcoClientError.invalidResponse
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")

        let payload: [String: Any] = [
            "html": html,
            "name": "DocMaker-generated.pdf"
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: payload)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw PDFcoClientError.invalidResponse
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            throw PDFcoClientError.requestFailed(httpResponse.statusCode)
        }

        guard
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let urlString = json["url"] as? String,
            let fileURL = URL(string: urlString)
        else {
            throw PDFcoClientError.invalidResponse
        }

        let (fileData, _) = try await session.data(from: fileURL)
        return fileData
    }
}
