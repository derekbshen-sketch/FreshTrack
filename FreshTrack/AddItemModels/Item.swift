//
//  Item.swift
//  FreshTrack
//

import Foundation
import SwiftUI

struct Item: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var category: String
    var expirationDate: Date
    var quantity: Double
    var quantityType: String
    var dateAdded: Date = Date()
    var imageData: Data? = nil

    var cost: Double?            // Optional cost (used by stats + grocery list)
    var price: Double?           // price with tax
    var taxIncluded: Bool        // flag

    var posX: CGFloat            // relative position in storage view
    var posY: CGFloat

    // history flag (optional, but useful if you ever want to filter)
    var isArchived: Bool = false

    var isExpired: Bool {
        expirationDate < Date()
    }

    var daysUntilExpiration: Int {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: Date())
        let end = calendar.startOfDay(for: expirationDate)
        let components = calendar.dateComponents([.day], from: start, to: end)
        return components.day ?? 0
    }

    var formattedExpiration: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: expirationDate)
    }

    init(
        id: UUID = UUID(),
        name: String,
        category: String,
        expirationDate: Date,
        quantity: Double,
        quantityType: String,
        cost: Double? = nil,
        price: Double? = nil,
        taxIncluded: Bool = true,
        dateAdded: Date = Date(),
        imageData: Data? = nil,
        posX: CGFloat = CGFloat.random(in: 0.15...0.85),
        posY: CGFloat = CGFloat.random(in: 0.15...0.85),
        isArchived: Bool = false
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.expirationDate = expirationDate
        self.quantity = quantity
        self.quantityType = quantityType
        self.cost = cost
        self.price = price
        self.taxIncluded = taxIncluded
        self.dateAdded = dateAdded
        self.imageData = imageData
        self.posX = posX
        self.posY = posY
        self.isArchived = isArchived
    }
}
