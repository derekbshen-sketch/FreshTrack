//
//  GroceryListHistoryState.swift
//  FreshTrack
//

import Foundation
import Combine

class GroceryListHistoryState: ObservableObject {
    @Published var history: [GroceryListHistoryItem] = [] {
        didSet { PersistenceManager.shared.saveGroceryHistory(history) }
    }

    @Published var lastSavedList: [String] = [] {
        didSet { PersistenceManager.shared.saveLastGroceryList(lastSavedList) }
    }

    init() {
        self.history = PersistenceManager.shared.loadGroceryHistory()
        self.lastSavedList = PersistenceManager.shared.loadLastGroceryList()
    }

    func saveList(_ itemNames: [String]) {
        lastSavedList = itemNames

        let entry = GroceryListHistoryItem(
            dateCreated: Date(),
            items: itemNames
        )
        history.append(entry)
    }

    func loadList(_ entry: GroceryListHistoryItem) -> [String] {
        return entry.items
    }

    func restoreLastList() -> [String] {
        return lastSavedList
    }

    func clearHistory() {
        history.removeAll()
    }
}
