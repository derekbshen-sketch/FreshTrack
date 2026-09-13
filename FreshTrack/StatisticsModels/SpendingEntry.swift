//
//  SpendingEntry.swift
//  FreshTrack
//
//  Created by Derek Shen on 8/3/26.
//

import Foundation

struct SpendingEntry: Identifiable, Codable {
    var id: UUID
    var itemName: String?
    var amount: Double
    var date: Date

    init(
        id: UUID = UUID(),
        itemName: String? = nil,
        amount: Double,
        date: Date = Date()
    ) {
        self.id = id
        self.itemName = itemName
        self.amount = amount
        self.date = date
    }
}

struct ItemSpendingSummary: Identifiable {
    let id = UUID()
    let name: String
    let total: Double
    let count: Int
}
