//
//  ReceiptAIEngine.swift
//  FreshTrack
//
//  Created by Derek Shen on 7/30/26.
//

import Foundation
import Vision
import UIKit

// MARK: - ScannedItem model

struct ScannedItem: Identifiable, Codable {
    var id = UUID()
    var name: String
    var quantity: Double
    var unit: QuantityUnit
    var category: String
    var expirationDate: Date
    var confidence: Double

    var costText: String = ""
}


// MARK: - ReceiptAIEngine

final class ReceiptAIEngine {

    static let shared = ReceiptAIEngine()

    private init() {}

    // MARK: - Public API

    /// Process a receipt image → returns parsed items + raw OCR lines
    func process(
        image: UIImage,
        completion: @escaping (_ items: [ScannedItem], _ ocrLines: [String]) -> Void
    ) {
        guard let cgImage = image.cgImage else {
            completion([], [])
            return
        }

        let request = VNRecognizeTextRequest { request, error in
            if let error {
                print("OCR Error: \(error.localizedDescription)")
                completion([], [])
                return
            }

            guard let results = request.results as? [VNRecognizedTextObservation] else {
                completion([], [])
                return
            }

            let linesWithConfidence: [(text: String, confidence: Double)] = results.compactMap { obs in
                guard let candidate = obs.topCandidates(1).first else { return nil }
                return (candidate.string, Double(candidate.confidence))
            }

            // Optional: filter out very low-confidence lines
            let minConfidence: Double = 0.3
            let filteredLinesWithConfidence = linesWithConfidence.filter { $0.confidence >= minConfidence }

            let rawLines = filteredLinesWithConfidence.map { $0.text }

            // Normalize each line into a possible food item
            let normalizedItems: [String] = rawLines.compactMap { self.normalizeItemName($0) }
            let detectedNames = normalizedItems

            let items: [ScannedItem] = detectedNames.map { name in
                let (qty, unit) = self.detectQuantity(for: name, in: rawLines)
                let category = self.detectCategory(for: name)
                let expiration = self.predictExpiration(for: name, category: category)
                let confidence = self.confidence(for: name, in: filteredLinesWithConfidence)

                return ScannedItem(
                    name: name,
                    quantity: qty,
                    unit: unit,
                    category: category,
                    expirationDate: expiration,
                    confidence: confidence,
                    costText: ""
                )
            }

            completion(items, rawLines)
        }

        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                print("OCR Handler Error: \(error.localizedDescription)")
                completion([], [])
            }
        }
    }

    // MARK: - Dictionaries

    private let brandMap: [String: String] = [
        // Cereals
        "cheerios": "cereal",
        "froot loops": "cereal",
        "frosted flakes": "cereal",
        "special k": "cereal",
        "raisin bran": "cereal",
        "corn flakes": "cereal",

        // Snacks
        "doritos": "chips",
        "lays": "chips",
        "pringles": "chips",
        "cheez it": "crackers",
        "goldfish": "crackers",
        "oreos": "cookies",
        "chips ahoy": "cookies",

        // Drinks
        "coke": "soda",
        "pepsi": "soda",
        "sprite": "soda",
        "gatorade": "sports drink",
        "powerade": "sports drink",

        // Frozen
        "di giorno": "frozen pizza",
        "red baron": "frozen pizza",
        "stouffers": "frozen meal",
        "lean cuisine": "frozen meal",

        // Bread
        "wonder bread": "bread",
        "sara lee": "bread",

        // Dairy
        "chobani": "yogurt",
        "yoplait": "yogurt",
        "tillamook": "cheese",
        "kraft": "cheese",

        // Meat
        "tyson": "chicken",
        "perdue": "chicken",
        "oscar mayer": "deli meat"
    ]

    private let abbreviationMap: [String: String] = [
        "mlk": "milk",
        "m1lk": "milk",
        "eg": "eggs",
        "brd": "bread",
        "chk": "chicken",
        "chkn": "chicken",
        "bcn": "bacon",
        "grbf": "ground beef",
        "ltc": "lettuce",
        "tmto": "tomatoes",
        "strbry": "strawberries",
        "blbry": "blueberries",
        "frz veg": "frozen vegetables",
        "frz chkn": "frozen chicken",
        "frz piz": "frozen pizza",
        "crt": "carrots",
        "apl": "apples",
        "grps": "grapes",
        "ygt": "yogurt",
        "chz": "cheese",
        "crm chz": "cream cheese",
        "s crm": "sour cream",
        "bn": "beans",
        "rce": "rice",
        "pst": "pasta",
        "flr": "flour",
        "sg": "sugar",
        "sl": "salt",
        "pep": "pepper"
    ]

    private let synonymMap: [String: String] = [
        "ground chuck": "ground beef",
        "ground round": "ground beef",
        "ribeye": "steak",
        "sirloin": "steak",
        "romaine": "lettuce",
        "iceberg": "lettuce",
        "bell pepper": "peppers",
        "capsicum": "peppers",
        "cuke": "cucumber",
        "spuds": "potatoes",
        "tater": "potatoes",
        "poultry": "chicken",
        "breast": "chicken breast",
        "thigh": "chicken",
        "drumstick": "chicken",
        "fillet": "fish",
        "filet": "fish",
        "salmon fillet": "salmon",
        "cod fillet": "cod",
        "shrimp cocktail": "shrimp",
        "berries": "blueberries",
        "strawb": "strawberries",
        "yog": "yogurt",
        "cream": "cream cheese",
        "sour": "sour cream"
    ]

    // MARK: - Normalization

    /// Returns a normalized item name, or nil if the line is not a food item.
    private func normalizeItemName(_ raw: String) -> String? {
        let lower = raw.lowercased()

        // Ignore obvious non-item lines
        let nonItemKeywords = [
            "subtotal", "total", "tax", "visa", "mastercard",
            "debit", "credit", "change", "cash", "card", "payment"
        ]
        if nonItemKeywords.contains(where: { lower.contains($0) }) {
            return nil
        }

        // 1. Brand mapping
        for (brand, mapped) in brandMap {
            if lower.contains(brand) {
                return mapped
            }
        }

        // 2. Abbreviation mapping
        for (abbr, mapped) in abbreviationMap {
            if lower.contains(abbr) {
                return mapped
            }
        }

        // 3. Synonym mapping
        for (syn, mapped) in synonymMap {
            if lower.contains(syn) {
                return mapped
            }
        }

        // 4. Exact match from expanded list (word-based, not substring)
        let words = lower.split(whereSeparator: { !$0.isLetter })
        for item in expandedItemList() {
            let itemLower = item.lowercased()
            if words.contains(where: { $0 == Substring(itemLower) }) {
                return item
            }
        }

        // 5. No fuzzy match anymore → if we didn’t hit anything, it’s not an item
        return nil
    }

    // MARK: - Fuzzy Matching

    private func levenshtein(_ a: String, _ b: String) -> Int {
        if a.isEmpty { return b.count }
        if b.isEmpty { return a.count }

        let aChars = Array(a)
        let bChars = Array(b)
        let aCount = aChars.count
        let bCount = bChars.count

        var dist = Array(repeating: Array(repeating: 0, count: bCount + 1), count: aCount + 1)

        for i in 0...aCount { dist[i][0] = i }
        for j in 0...bCount { dist[0][j] = j }

        if aCount == 0 || bCount == 0 {
            return dist[aCount][bCount]
        }

        for i in 1...aCount {
            for j in 1...bCount {
                if aChars[i - 1] == bChars[j - 1] {
                    dist[i][j] = dist[i - 1][j - 1]
                } else {
                    dist[i][j] = min(
                        dist[i - 1][j] + 1,
                        dist[i][j - 1] + 1,
                        dist[i - 1][j - 1] + 1
                    )
                }
            }
        }

        return dist[aCount][bCount]
    }

    private func fuzzyMatch(_ raw: String) -> String? {
        let lower = raw.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        if lower.isEmpty { return nil }
        if lower.count < 3 { return nil }   // avoid matching "to", "x", etc.

        let items = expandedItemList()

        var bestItem: String?
        var bestScore = Int.max

        for item in items {
            let score = levenshtein(lower, item.lowercased())
            if score < bestScore {
                bestScore = score
                bestItem = item
            }
        }

        // threshold: allow up to 2 edits
        if bestScore <= 2 {
            return bestItem
        }

        return nil
    }

    // MARK: - Quantity + Unit detection

    private func detectQuantity(for item: String, in lines: [String]) -> (Double, QuantityUnit) {
        let lowerItem = item.lowercased()

        for line in lines {
            let lower = line.lowercased()

            guard lower.contains(lowerItem) else { continue }

            // MULTIPLIER: "2x Milk"
            if let range = lower.range(of: #"(\d+)\s*x"#, options: .regularExpression) {
                let digits = String(lower[range]).filter { "0123456789".contains($0) }
                let num = Double(digits) ?? 1
                return (num, .items)
            }

            // SIMPLE NUMBER: "Milk 3"
            if let range = lower.range(of: #"(\d+)"#, options: .regularExpression) {
                let digits = String(lower[range]).filter { "0123456789".contains($0) }
                let num = Double(digits) ?? 1
                return (num, .items)
            }

            // GRAMS: "500g"
            if let range = lower.range(of: #"(\d+)\s*g"#, options: .regularExpression) {
                let digits = String(lower[range]).filter { "0123456789".contains($0) }
                let num = Double(digits) ?? 1
                return (num, .grams)
            }

            // KILOGRAMS: "2kg"
            if let range = lower.range(of: #"(\d+)\s*kg"#, options: .regularExpression) {
                let digits = String(lower[range]).filter { "0123456789".contains($0) }
                let num = Double(digits) ?? 1
                return (num, .kilograms)
            }

            // OUNCES: "12oz"
            if let range = lower.range(of: #"(\d+)\s*oz"#, options: .regularExpression) {
                let digits = String(lower[range]).filter { "0123456789".contains($0) }
                let num = Double(digits) ?? 1
                return (num, .ounces)
            }

            // POUNDS: "1lb"
            if let range = lower.range(of: #"(\d+)\s*lb"#, options: .regularExpression) {
                let digits = String(lower[range]).filter { "0123456789".contains($0) }
                let num = Double(digits) ?? 1
                return (num, .pounds)
            }
        }

        return (1, .items)
    }

    // MARK: - Category detection

    private func detectCategory(for item: String) -> String {
        let lower = item.lowercased()

        let fridgeItems = [
            "milk","eggs","yogurt","cheese","butter","cream cheese","sour cream",
            "juice","deli meat","ham","turkey","chicken breast","ground beef",
            "fresh fish","lettuce","spinach","broccoli","carrots","tomatoes",
            "onions","apples","grapes","strawberries","blueberries","avocado",
            "cucumber","celery"
        ]

        let freezerItems = [
            "ice cream","frozen pizza","frozen vegetables","frozen fruit",
            "frozen chicken","frozen beef","frozen shrimp","frozen salmon",
            "frozen fries","frozen waffles","frozen burritos","frozen lasagna",
            "frozen meatballs","frozen nuggets","frozen sausage"
        ]

        if fridgeItems.contains(where: { lower.contains($0) }) {
            return "Fridge"
        }

        if freezerItems.contains(where: { lower.contains($0) }) {
            return "Freezer"
        }

        return "Pantry"
    }

    // MARK: - Expiration prediction

    private func predictExpiration(for item: String, category: String) -> Date {
        let lower = item.lowercased()
        let now = Date()

        if category == "Fridge" {
            if lower.contains("milk") { return now.addingTimeInterval(60 * 60 * 24 * 7) }
            if lower.contains("eggs") { return now.addingTimeInterval(60 * 60 * 24 * 21) }
            if lower.contains("yogurt") { return now.addingTimeInterval(60 * 60 * 24 * 14) }
            if lower.contains("cheese") { return now.addingTimeInterval(60 * 60 * 24 * 30) }
            return now.addingTimeInterval(60 * 60 * 24 * 10)
        }

        if category == "Freezer" {
            return now.addingTimeInterval(60 * 60 * 24 * 180)
        }

        if lower.contains("bread") { return now.addingTimeInterval(60 * 60 * 24 * 5) }
        if lower.contains("chips") { return now.addingTimeInterval(60 * 60 * 24 * 60) }
        if lower.contains("cereal") { return now.addingTimeInterval(60 * 60 * 24 * 120) }

        return now.addingTimeInterval(60 * 60 * 24 * 30)
    }

    // MARK: - Confidence scoring

    private func confidence(
        for item: String,
        in lines: [(text: String, confidence: Double)]
    ) -> Double {
        let lowerItem = item.lowercased()
        var best: Double = 0.0

        for (text, conf) in lines {
            if text.lowercased().contains(lowerItem) {
                best = max(best, conf)
            }
        }

        return best
    }

    // MARK: - Expanded Item List

    private func expandedItemList() -> [String] {
        return [

            // PANTRY
            "almonds","avocado oil","bagels","baking powder","baking soda",
            "beans","bread","brown sugar","canned chicken","canned fruit",
            "canned soup","canned tomatoes","canned tuna","canned vegetables",
            "cereal","chips","chocolate chips","coffee","cookies","crackers",
            "flour","garlic powder","ginger powder","granola","honey","jam",
            "lasagna noodles","mac and cheese","mayonnaise","mustard","nuts",
            "oatmeal","olive oil","onion powder","pasta","peanut butter",
            "pepper","popcorn","pretzels","ramen","rice","salt","salsa",
            "soy sauce","spaghetti","sugar","tortillas","vinegar","walnuts",

            // FRIDGE
            "apples","avocado","bacon","blueberries","broccoli","butter",
            "carrots","celery","cheese","chicken breast","cream cheese",
            "cucumber","deli meat","eggs","fresh fish","grapes","ground beef",
            "ham","juice","lettuce","milk","onions","spinach","strawberries",
            "tomatoes","turkey","yogurt",

            // FREEZER
            "frozen beef","frozen burritos","frozen chicken","frozen fruit",
            "frozen fries","frozen lasagna","frozen meatballs","frozen nuggets",
            "frozen pizza","frozen salmon","frozen sausage","frozen shrimp",
            "frozen vegetables","frozen waffles","ice cream"
        ]
    }
}
