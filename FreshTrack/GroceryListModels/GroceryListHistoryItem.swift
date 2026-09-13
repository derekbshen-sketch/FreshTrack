//
//  GroceryListHistory.swift
//  FreshTrack
//
//  Created by Derek Shen on 8/3/26.
//

import Foundation

struct GroceryListHistoryItem: Identifiable, Codable {
    let id: UUID
    let dateCreated: Date
    let items: [String]      // names only, matches your saveList(names)

    init(
        id: UUID = UUID(),
        dateCreated: Date,
        items: [String]
    ) {
        self.id = id
        self.dateCreated = dateCreated
        self.items = items
    }
}



