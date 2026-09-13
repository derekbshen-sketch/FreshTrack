//
//  HistoryView.swift
//  FreshTrack
//
//  Created by Derek Shen on 8/4/26.
//

import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var receiptHistory: ReceiptHistoryState
    @EnvironmentObject var itemState: ItemState
    @EnvironmentObject var groceryListHistory: GroceryListHistoryState
    @EnvironmentObject var groceryListState: GroceryListState
    @EnvironmentObject var settingsState: SettingsState

    var body: some View {

        // ⭐ FULL SCREEN THEME BACKGROUND
        ZStack {
            appBackground(for: settingsState.selectedTheme)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 32) {

                    // RECEIPT HISTORY
                    historyHeader("Receipt History")

                    if receiptHistory.history.isEmpty {
                        emptyText("No receipts saved.")
                    } else {
                        VStack(spacing: 12) {
                            ForEach(receiptHistory.history) { entry in
                                NavigationLink {
                                    ReceiptHistoryDetailView(entry: entry)
                                        .environmentObject(settingsState)
                                } label: {
                                    historyRow(
                                        title: "Receipt",
                                        subtitle: formatted(entry.dateScanned)
                                    )
                                }
                            }
                        }
                    }

                    // STORED ITEMS HISTORY
                    historyHeader("Stored Items")

                    if itemState.items.isEmpty {
                        emptyText("No stored items.")
                    } else {
                        VStack(spacing: 12) {
                            ForEach(itemState.items) { item in
                                historyRow(
                                    title: item.name,
                                    subtitle: "Expires: \(item.formattedExpiration)"
                                )
                            }
                        }
                    }

                    // EXPIRED ITEMS HISTORY
                    historyHeader("Expired Items")

                    let expired = itemState.items.filter { $0.isExpired }

                    if expired.isEmpty {
                        emptyText("No expired items.")
                    } else {
                        VStack(spacing: 12) {
                            ForEach(expired) { item in
                                historyRow(
                                    title: item.name,
                                    subtitle: "Expired: \(item.formattedExpiration)"
                                )
                            }
                        }
                    }

                    // GROCERY LIST HISTORY
                    historyHeader("Grocery List History")

                    if groceryListHistory.history.isEmpty {
                        emptyText("No grocery list history.")
                    } else {
                        VStack(spacing: 12) {
                            ForEach(groceryListHistory.history) { entry in
                                HStack {
                                    NavigationLink {
                                        GroceryListHistoryDetailView(entry: entry)
                                            .environmentObject(settingsState)
                                    } label: {
                                        historyRow(
                                            title: "List from \(formatted(entry.dateCreated))",
                                            subtitle: "\(entry.items.count) items"
                                        )
                                    }

                                    Spacer()

                                    Button("Restore") {
                                        restoreList(entry)
                                    }
                                    .padding(6)
                                    .background(Color.green.opacity(0.2))
                                    .cornerRadius(8)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)
            }
            .scrollContentBackground(.hidden)
            .background(Color.clear)
        }
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Restore Grocery List
    func restoreList(_ entry: GroceryListHistoryItem) {
        groceryListState.clearAllCheckmarks()

        groceryListState.items = entry.items.map { name in
            Item(
                name: name,
                category: "Pantry",
                expirationDate: Date().addingTimeInterval(86400 * 30),
                quantity: 1,
                quantityType: "items"
            )
        }
    }

    // MARK: - Helpers
    func historyHeader(_ title: String) -> some View {
        Text(title)
            .font(.title2)
            .fontWeight(.bold)
            .foregroundColor(
                themedAccent(
                    for: settingsState.selectedTheme,
                    accent: settingsState.accentColor
                )
            )
            .padding(.bottom, 4)
    }

    func historyRow(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
                .foregroundColor(themedTextColor(for: settingsState.selectedTheme))

            Text(subtitle)
                .foregroundColor(
                    themedTextColor(for: settingsState.selectedTheme).opacity(0.7)
                )
        }
        .padding(.vertical, 6)
    }

    func emptyText(_ text: String) -> some View {
        Text(text)
            .foregroundColor(
                themedTextColor(for: settingsState.selectedTheme).opacity(0.7)
            )
            .padding(.vertical, 6)
    }

    func formatted(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f.string(from: date)
    }
}
