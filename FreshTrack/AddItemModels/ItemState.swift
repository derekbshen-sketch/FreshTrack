//
//  ItemState.swift
//  FreshTrack
//

import SwiftUI
import Combine

class ItemState: ObservableObject {
    @Published var items: [Item] = [] {
        didSet { PersistenceManager.shared.saveItems(items) }
    }

    @Published var history: [Item] = [] {
        didSet { PersistenceManager.shared.saveHistory(history) }
    }

    init() {
        self.items = PersistenceManager.shared.loadItems()
        self.history = PersistenceManager.shared.loadHistory()
    }

    func addItem(_ item: Item, settingsState: SettingsState, alertState: AlertState) {
        items.append(item)
        alertState.addAutoAlert(for: item, settings: settingsState)
    }

    func removeItem(_ item: Item, alertState: AlertState) {
        alertState.deleteAlerts(for: item)

        var archived = item
        archived.isArchived = true
        history.append(archived)

        items.removeAll { $0.id == item.id }
    }

    func updateItem(_ item: Item, name: String, quantity: Double, unit: QuantityUnit) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].name = name
            items[index].quantity = quantity
            items[index].quantityType = unit.rawValue
        }
    }

    func updatePosition(_ item: Item, x: CGFloat, y: CGFloat) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].posX = x
            items[index].posY = y
        }
    }

    func restoreItem(_ item: Item, settingsState: SettingsState, alertState: AlertState) {
        guard let index = history.firstIndex(where: { $0.id == item.id }) else { return }
        var restored = history[index]
        restored.isArchived = false
        history.remove(at: index)
        addItem(restored, settingsState: settingsState, alertState: alertState)
    }

    func clearAllItemsAndHistory() {
        items.removeAll()
        history.removeAll()
    }
}
