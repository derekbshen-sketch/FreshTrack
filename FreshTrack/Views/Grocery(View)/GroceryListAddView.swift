//
//  GroceryListAddView.swift
//  FreshTrack
//
//  Created by Derek Shen on 7/30/26.
//

import SwiftUI

struct GroceryListAddView: View {
    @EnvironmentObject var groceryListState: GroceryListState
    @EnvironmentObject var settingsState: SettingsState
    @Environment(\.dismiss) var dismiss

    @State private var name: String = ""
    @State private var category: String = "Pantry"
    @State private var quantity: Double = 1
    @State private var unit: QuantityUnit = .items

    @State private var costInput: String = ""
    @State private var cost: Double? = nil

    @State private var showError = false

    let categories = ["Pantry", "Fridge", "Freezer"]

    var body: some View {

        // ⭐ FULL SCREEN THEME BACKGROUND
        ZStack {
            appBackground(for: settingsState.selectedTheme)
                .ignoresSafeArea()

            NavigationView {
                Form {

                    Section(header: Text("Item Details")
                        .foregroundColor(themedTextColor(for: settingsState.selectedTheme))
                    ) {
                        TextField("Name (required)", text: $name)

                        Picker("Category", selection: $category) {
                            ForEach(categories, id: \.self) { cat in
                                Text(cat).tag(cat)
                            }
                        }
                    }

                    Section(header: Text("Quantity")
                        .foregroundColor(themedTextColor(for: settingsState.selectedTheme))
                    ) {
                        HStack {
                            TextField("Amount", value: $quantity, formatter: NumberFormatter())
                                .keyboardType(.decimalPad)
                                .toolbar {
                                        ToolbarItemGroup(placement: .keyboard) {
                                            Spacer()
                                            Button("Done") {
                                                UIApplication.shared.sendAction(
                                                    #selector(UIResponder.resignFirstResponder),
                                                    to: nil, from: nil, for: nil
                                                )
                                            }
                                        }
                                    }

                            Picker("Unit", selection: $unit) {
                                ForEach(QuantityUnit.allCases, id: \.self) { u in
                                    Text(u.rawValue).tag(u)
                                }
                            }
                        }
                    }

                    Section(header: Text("Cost (optional)")
                        .foregroundColor(themedTextColor(for: settingsState.selectedTheme))
                    ) {
                        TextField("Cost ($)", text: $costInput)
                            .keyboardType(.decimalPad)
                            .onChange(of: costInput) {
                                cost = Double(costInput)
                            }
                    }

                    if showError {
                        Section {
                            Text("Please fill out the name.")
                                .foregroundColor(.red)
                        }
                    }

                    Section {
                        Button("Add to Grocery List") {
                            addItem()
                        }
                        .foregroundColor(
                            themedAccent(
                                for: settingsState.selectedTheme,
                                accent: settingsState.accentColor
                            )
                        )
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .navigationTitle("Add Grocery Item")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
            }
        }
    }

    func addItem() {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            showError = true
            return
        }

        let newItem = Item(
            name: name,
            category: category,
            expirationDate: Date(),
            quantity: quantity,
            quantityType: unit.rawValue,
            cost: cost
        )

        groceryListState.addItem(newItem)
        dismiss()
    }
}
