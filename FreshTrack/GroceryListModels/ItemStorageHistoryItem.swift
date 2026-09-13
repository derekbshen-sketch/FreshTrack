//
//  ItemStorageHistoryItem.swift
//  FreshTrack
//
//  Created by Derek Shen on 8/3/26.
//

import Foundation

struct ItemStorageHistoryItem: Identifiable, Codable {
    let id: UUID
    let dateStored: Date
    let item: Item

    init(
        id: UUID = UUID(),
        dateStored: Date,
        item: Item
    ) {
        self.id = id
        self.dateStored = dateStored
        self.item = item
    }
}

