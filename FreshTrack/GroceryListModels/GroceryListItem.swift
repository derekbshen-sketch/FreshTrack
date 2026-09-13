//
//  GroceryListItem.swift
//  FreshTrack
//
//  Created by Derek Shen on 7/29/26.
//

import Foundation

struct GroceryListItem: Identifiable, Codable {
    let id: UUID
    var name: String
    var quantity: Double
    var unit: String

    var price: Double?          // price with tax
    var taxIncluded: Bool       // flag

    init(
        id: UUID = UUID(),
        name: String,
        quantity: Double,
        unit: String,
        price: Double? = nil,
        taxIncluded: Bool = true
    ) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.unit = unit
        self.price = price
        self.taxIncluded = taxIncluded
    }
}
