//
//  ReceiptOCR.swift
//  FreshTrack
//
//  Created by Derek Shen on 7/29/26.
//

import Vision
import UIKit

class ReceiptOCR {
    static func extractText(from image: UIImage, completion: @escaping (String) -> Void) {
        guard let cgImage = image.cgImage else { return }

        let request = VNRecognizeTextRequest { request, error in
            guard let results = request.results as? [VNRecognizedTextObservation] else {
                completion("")
                return
            }

            let text = results.compactMap { $0.topCandidates(1).first?.string }.joined(separator: "\n")
            completion(text)
        }

        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try? handler.perform([request])
    }
}
