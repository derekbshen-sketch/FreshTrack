//
//  GroceryListHistoryView.swift
//  FreshTrack
//
//  Created by Derek Shen on 8/3/26.
//

import SwiftUI

struct GroceryListHistoryView: View {
    @EnvironmentObject var groceryListHistory: GroceryListHistoryState
    @EnvironmentObject var groceryListState: GroceryListState
    @EnvironmentObject var settingsState: SettingsState

    @State private var showClearWarning = false

    var body: some View {

        // ⭐ FULL SCREEN THEME BACKGROUND
        ZStack {
            appBackground(for: settingsState.selectedTheme)
                .ignoresSafeArea()

            VStack {
                if groceryListHistory.history.isEmpty {
                    Text("No grocery list history.")
                        .foregroundColor(
                            themedTextColor(for: settingsState.selectedTheme).opacity(0.7)
                        )
                        .padding()
                } else {
                    List {
                        ForEach(groceryListHistory.history) { entry in
                            HStack {
                                NavigationLink {
                                    GroceryListHistoryDetailView(entry: entry)
                                        .environmentObject(settingsState)
                                } label: {
                                    VStack(alignment: .leading) {
                                        Text("List from \(formatted(entry.dateCreated))")
                                            .font(.headline)
                                            .foregroundColor(
                                                themedTextColor(for: settingsState.selectedTheme)
                                            )

                                        Text("\(entry.items.count) items")
                                            .foregroundColor(
                                                themedTextColor(for: settingsState.selectedTheme).opacity(0.7)
                                            )
                                    }
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
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                }

                Button("Clear All History") {
                    showClearWarning = true
                }
                .foregroundColor(.red)
                .padding()
                .alert("Clear All Grocery List History?",
                       isPresented: $showClearWarning) {
                    Button("Delete All", role: .destructive) {
                        groceryListHistory.clearHistory()
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("This action cannot be undone.")
                }
            }
        }
        .navigationTitle("Grocery List History")
    }

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

    func formatted(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f.string(from: date)
    }
}

