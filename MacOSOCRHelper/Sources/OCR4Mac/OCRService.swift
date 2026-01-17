import Foundation
import Vision
import AppKit

final class OCRService: Sendable {
    static let shared = OCRService()

    func recognizeText(from image: CGImage) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(returning: "")
                    return
                }

                let recognizedStrings = observations.compactMap { observation in
                    observation.topCandidates(1).first?.string
                }

                let result = recognizedStrings.joined(separator: "\n")
                continuation.resume(returning: result)
            }

            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true
            // Prioritize Chinese (Simplified & Traditional), then English, Japanese, Korean
            request.recognitionLanguages = ["zh-Hans", "zh-Hant", "en-US", "ja-JP", "ko-KR"]

            let handler = VNImageRequestHandler(cgImage: image, options: [:])

            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}
