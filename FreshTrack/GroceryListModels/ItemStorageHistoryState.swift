//
//  ItemStorageHistoryState.swift
//  FreshTrack
//
//  Created by Derek Shen on 8/3/26.
//

import Foundation
import Combine

class ItemStorageHistoryState: ObservableObject {
    @Published var history: [ItemStorageHistoryItem] = []

    func addStoredItem(_ item: Item) {
        let entry = ItemStorageHistoryItem(
            dateStored: Date(),
            item: item
        )
        history.append(entry)
    }

    func clearHistory() {
        history.removeAll()
    }
}


