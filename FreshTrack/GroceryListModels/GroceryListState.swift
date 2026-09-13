//
//  GroceryListState.swift
//  FreshTrack
//

import SwiftUI
import Combine
import Foundation

class GroceryListState: ObservableObject {
    @Published var items: [Item] = [] {
        didSet { PersistenceManager.shared.saveGroceryList(items) }
    }

    @Published private var checkedItemIDs: Set<UUID> = [] {
        didSet { PersistenceManager.shared.saveCheckedIDs(checkedItemIDs) }
    }
    
    var alertState: AlertState?

    init() {
        self.items = PersistenceManager.shared.loadGroceryList()
        self.checkedItemIDs = PersistenceManager.shared.loadCheckedIDs()
    }

    func attachAlertState(_ alertState: AlertState) {
        self.alertState = alertState
    }

    func addItem(_ item: Item) {
        items.append(item)
    }

    func removeItems(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
    }

    func toggleChecked(_ item: Item, quantity: Double, unit: QuantityUnit) {
        if checkedItemIDs.contains(item.id) {
            checkedItemIDs.remove(item.id)
        } else {
            checkedItemIDs.insert(item.id)
        }

        updateQuantity(item, quantity: quantity, unit: unit)
    }

    func isChecked(_ item: Item) -> Bool {
        checkedItemIDs.contains(item.id)
    }

    func updateQuantity(_ item: Item, quantity: Double, unit: QuantityUnit) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].quantity = quantity
            items[index].quantityType = unit.rawValue
        }
    }
    
    func clearAllCheckmarks() {
        checkedItemIDs.removeAll()
    }

    var totalEstimatedCost: Double {
        items.compactMap { $0.cost }.reduce(0, +)
    }

    func updateCost(_ item: Item, cost: Double?) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].cost = cost
        }
    }
}
