//
//  GroceryListView.swift
//  FreshTrack
//
//  Created by Derek Shen on 7/29/26.
//

import SwiftUI
import Combine

struct GroceryListView: View {
    @EnvironmentObject var groceryListState: GroceryListState
    @EnvironmentObject var settingsState: SettingsState
    @EnvironmentObject var groceryListHistory: GroceryListHistoryState
    @EnvironmentObject var itemState: ItemState

    @State private var showAddSheet = false

    var body: some View {

        // ⭐ FULL SCREEN THEME BACKGROUND
        ZStack {
            appBackground(for: settingsState.selectedTheme)
                .ignoresSafeArea()

            VStack {
                Text("Grocery List")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(
                        themedAccent(
                            for: settingsState.selectedTheme,
                            accent: settingsState.accentColor
                        )
                    )
                    .padding(.top)

                List {
                    ForEach(groceryListState.items.filter { !groceryListState.isChecked($0) }) { item in
                        GroceryListRow(item: item)
                            .environmentObject(groceryListState)
                            .environmentObject(itemState)
                            .environmentObject(settingsState)
                    }
                    .onDelete(perform: groceryListState.removeItems)
                }
                .scrollContentBackground(.hidden)
                .background(Color.clear)

                Spacer()

                Button {
                    showAddSheet = true
                } label: {
                    Text("Add Grocery Item")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(settingsState.accentColor)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }

                Button {
                    let names = groceryListState.items.map { $0.name }
                    groceryListHistory.saveList(names)
                } label: {
                    Text("Save List to History")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }

                Button {
                    let restoredNames = groceryListHistory.restoreLastList()
                    groceryListState.items = restoredNames.map {
                        Item(
                            name: $0,
                            category: "Pantry",
                            expirationDate: Date().addingTimeInterval(86400 * 30),
                            quantity: 1,
                            quantityType: "items"
                        )
                    }
                } label: {
                    Text("Restore Last List")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(12)
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                }
            }
        }
        .sheet(isPresented: $showAddSheet) {
            GroceryListAddView()
                .environmentObject(groceryListState)
                .environmentObject(settingsState)
        }
        .navigationTitle("Grocery List")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct GroceryListRow: View {
    @EnvironmentObject var groceryListState: GroceryListState
    @EnvironmentObject var itemState: ItemState
    @EnvironmentObject var settingsState: SettingsState
    @EnvironmentObject var alertState: AlertState

    var item: Item

    @State private var quantity: Double
    @State private var unit: QuantityUnit

    @State private var showExpirationPrompt = false
    @State private var tempExpirationDate = Date()

    init(item: Item) {
        self.item = item
        _quantity = State(initialValue: item.quantity)
        _unit = State(initialValue: QuantityUnit(rawValue: item.quantityType) ?? .items)
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                    .foregroundColor(.primary)

                Text("\(item.quantity.cleanString()) \(item.quantityType)")
                    .font(.subheadline)
                    .foregroundColor(
                        .secondary
                    )

                // ⭐ NEW: Show estimated cost if available
                if let cost = item.cost {
                    Text("Estimated: $\(cost.cleanString())")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }

            Spacer()

            Button {
                showExpirationPrompt = true
            } label: {
                Image(systemName: groceryListState.isChecked(item) ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(groceryListState.isChecked(item) ? .green : .gray)
                    .font(.title2)
            }
        }
        .onChange(of: quantity) { _, newValue in
            groceryListState.updateQuantity(item, quantity: newValue, unit: unit)
        }
        .onChange(of: unit) { _, newUnit in
            groceryListState.updateQuantity(item, quantity: quantity, unit: newUnit)
        }
        .sheet(isPresented: $showExpirationPrompt) {
            ExpirationDatePrompt(
                item: item,
                quantity: quantity,
                unit: unit,
                selectedDate: $tempExpirationDate,
                onConfirm: { date in

                    // ⭐ NEW: Carry cost into stored item
                    let newItem = Item(
                        name: item.name,
                        category: item.category,
                        expirationDate: date,
                        quantity: quantity,
                        quantityType: unit.rawValue,
                        cost: item.cost,                 // ← cost carried over
                        price: item.price,
                        taxIncluded: item.taxIncluded
                    )

                    itemState.addItem(newItem, settingsState: settingsState, alertState: alertState)

                    groceryListState.toggleChecked(item, quantity: quantity, unit: unit)
                }
            )
        }
    }
}
