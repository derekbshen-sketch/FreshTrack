//
//  ReceiptParser.swift
//  FreshTrack
//
//  Created by Derek Shen on 7/29/26.
//

import Foundation

class ReceiptParser {
    static func parseItems(from text: String) -> [ParsedItem] {
        var items: [ParsedItem] = []

        let lines = text.components(separatedBy: .newlines)

        for line in lines {
            let cleaned = line.lowercased()

            // Examples:
            // "Milk 2" → name: Milk, qty: 2
            // "Bananas 450g" → name: Bananas, qty: 450g
            // "Chips x3" → name: Chips, qty: 3 packets (Going to happen soon TRUST ME!!!)

            if cleaned.contains("g") {
                if let qty = Int(cleaned.filter("0123456789".contains)) {
                    let name = cleaned.replacingOccurrences(of: "\(qty)g", with: "").trimmingCharacters(in: .whitespaces)
                    items.append(ParsedItem(name: name.capitalized, quantity: qty, type: .grams))
                }
            } else if cleaned.contains("x") {
                let parts = cleaned.split(separator: "x")
                if parts.count == 2, let qty = Int(parts[1]) {
                    let name = parts[0].trimmingCharacters(in: .whitespaces)
                    items.append(ParsedItem(name: name.capitalized, quantity: qty, type: .packets))
                }
            } else {
                let parts = cleaned.split(separator: " ")
                if parts.count >= 2, let qty = Int(parts.last!) {
                    let name = parts.dropLast().joined(separator: " ")
                    items.append(ParsedItem(name: name.capitalized, quantity: qty, type: .items))
                }
            }
        }

        return items
    }
}

struct ParsedItem {
    let name: String
    let quantity: Int
    let type: QuantityUnit
}
