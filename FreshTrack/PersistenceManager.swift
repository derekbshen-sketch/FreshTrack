//
//  PersistenceManager.swift
//  FreshTrack
//

import Foundation

class PersistenceManager {

    static let shared = PersistenceManager()
    private init() {}

    // MARK: - Base directory
    private var documents: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    // MARK: - File URLs
    private var itemsURL: URL { documents.appendingPathComponent("items.json") }
    private var historyURL: URL { documents.appendingPathComponent("itemHistory.json") }
    private var alertsURL: URL { documents.appendingPathComponent("alerts.json") }
    private var settingsURL: URL { documents.appendingPathComponent("settings.json") }

    private var groceryListURL: URL { documents.appendingPathComponent("groceryList.json") }
    private var checkedIDsURL: URL { documents.appendingPathComponent("checkedIDs.json") }

    private var itemStorageHistoryURL: URL {
        documents.appendingPathComponent("itemStorageHistory.json")
    }

    private var groceryHistoryURL: URL { documents.appendingPathComponent("groceryHistory.json") }
    private var lastGroceryListURL: URL { documents.appendingPathComponent("lastGroceryList.json") }

    private var receiptHistoryURL: URL { documents.appendingPathComponent("receiptHistory.json") }

    private var statisticsURL: URL { documents.appendingPathComponent("statistics.json") }

    private var budgetURL: URL { documents.appendingPathComponent("budget.json") }

    // MARK: - Generic Save
    private func save<T: Codable>(_ value: T, to url: URL) {
        do {
            let data = try JSONEncoder().encode(value)
            try data.write(to: url)
        } catch {
            print("❌ Error saving to \(url.lastPathComponent):", error)
        }
    }

    // MARK: - Generic Load
    private func load<T: Codable>(_ type: T.Type, from url: URL) -> T? {
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(type, from: data)
        } catch {
            return nil
        }
    }

    // MARK: - Items
    func saveItems(_ items: [Item]) { save(items, to: itemsURL) }
    func loadItems() -> [Item] { load([Item].self, from: itemsURL) ?? [] }

    // MARK: - Item History
    func saveHistory(_ history: [Item]) { save(history, to: historyURL) }
    func loadHistory() -> [Item] { load([Item].self, from: historyURL) ?? [] }

    // MARK: - Alerts
    func saveAlerts(_ alerts: [AlertItem]) { save(alerts, to: alertsURL) }
    func loadAlerts() -> [AlertItem] { load([AlertItem].self, from: alertsURL) ?? [] }

    // MARK: - Settings
    func saveSettings(_ settings: SettingsStateCodable) { save(settings, to: settingsURL) }
    func loadSettings() -> SettingsStateCodable? { load(SettingsStateCodable.self, from: settingsURL) }

    // MARK: - Grocery List
    func saveGroceryList(_ items: [Item]) { save(items, to: groceryListURL) }
    func loadGroceryList() -> [Item] { load([Item].self, from: groceryListURL) ?? [] }

    // MARK: - Checked Grocery IDs
    func saveCheckedIDs(_ ids: Set<UUID>) {
        save(Array(ids), to: checkedIDsURL)
    }
    func loadCheckedIDs() -> Set<UUID> {
        let array = load([UUID].self, from: checkedIDsURL) ?? []
        return Set(array)
    }

    // MARK: - Grocery List History
    func saveGroceryHistory(_ history: [GroceryListHistoryItem]) {
        save(history, to: groceryHistoryURL)
    }
    func loadGroceryHistory() -> [GroceryListHistoryItem] {
        load([GroceryListHistoryItem].self, from: groceryHistoryURL) ?? []
    }

    // MARK: - Last Saved Grocery List
    func saveLastGroceryList(_ list: [String]) {
        save(list, to: lastGroceryListURL)
    }
    func loadLastGroceryList() -> [String] {
        load([String].self, from: lastGroceryListURL) ?? []
    }

    // MARK: - Receipt History
    func saveReceiptHistory(_ history: [ReceiptHistoryItem]) {
        save(history, to: receiptHistoryURL)
    }
    func loadReceiptHistory() -> [ReceiptHistoryItem] {
        load([ReceiptHistoryItem].self, from: receiptHistoryURL) ?? []
    }

    // MARK: - Statistics
    func saveStatistics(_ entries: [SpendingEntry]) {
        save(entries, to: statisticsURL)
    }
    func loadStatistics() -> [SpendingEntry] {
        load([SpendingEntry].self, from: statisticsURL) ?? []
    }

    // MARK: - Budget
    func saveBudget(_ budget: BudgetStateCodable) {
        save(budget, to: budgetURL)
    }
    func loadBudget() -> BudgetStateCodable? {
        load(BudgetStateCodable.self, from: budgetURL)
    }
    
    // MARK: - Item Storage History Items
    func saveItemStorageHistory(_ history: [ItemStorageHistoryItem]) {
        save(history, to: itemStorageHistoryURL)
    }

    func loadItemStorageHistory() -> [ItemStorageHistoryItem] {
        load([ItemStorageHistoryItem].self, from: itemStorageHistoryURL) ?? []
    }
    
    
    
}
