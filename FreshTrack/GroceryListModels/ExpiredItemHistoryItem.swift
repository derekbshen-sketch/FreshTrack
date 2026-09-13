//
//  ExpiredItemHistoryItem.swift
//  FreshTrack
//
//  Created by Derek Shen on 8/3/26.
//

import Foundation

struct ExpiredItemHistoryItem: Identifiable, Codable {
    let id: UUID
    let dateExpired: Date
    let item: Item

    init(
        id: UUID = UUID(),
        dateExpired: Date,
        item: Item
    ) {
        self.id = id
        self.dateExpired = dateExpired
        self.item = item
    }
}


