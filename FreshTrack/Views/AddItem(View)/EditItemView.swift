//
//  EditItemView.swift
//  FreshTrack
//
//  Created by Derek Shen on 7/29/26.
//

import SwiftUI

struct EditItemView: View {
    @EnvironmentObject var itemState: ItemState
    @EnvironmentObject var settingsState: SettingsState
    @EnvironmentObject var alertState: AlertState
    @Environment(\.dismiss) var dismiss

    @State private var name: String
    @State private var category: String
    @State private var quantity: Double
    @State private var unit: QuantityUnit
    @State private var expirationDate: Date

    let item: Item
    let categories = ["Pantry", "Fridge", "Freezer"]

    init(item: Item) {
        self.item = item
        _name = State(initialValue: item.name)
        _category = State(initialValue: item.category)
        _quantity = State(initialValue: item.quantity)
        _unit = State(initialValue: QuantityUnit(rawValue: item.quantityType) ?? .items)
        _expirationDate = State(initialValue: item.expirationDate)
    }

    var body: some View {

        ZStack {
            appBackground(for: settingsState.selectedTheme)
                .ignoresSafeArea()

            Form {

                Section(header: Text("Item Details")
                    .foregroundColor(themedTextColor(for: settingsState.selectedTheme))
                ) {
                    TextField("Name", text: $name)

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

                Section(header: Text("Expiration Date")
                    .foregroundColor(themedTextColor(for: settingsState.selectedTheme))
                ) {
                    NavigationLink {
                        ExpirationPickerView(initialDate: expirationDate) { newDate in
                            expirationDate = newDate
                        }
                    } label: {
                        HStack {
                            Text("Expires On")
                            Spacer()
                            Text(formatted(expirationDate))
                                .foregroundColor(themedTextColor(for: settingsState.selectedTheme).opacity(0.7))
                        }
                    }
                }

                Section {
                    Button("Save Changes") {
                        saveItem()
                        dismiss()
                    }
                    .foregroundColor(
                        themedAccent(
                            for: settingsState.selectedTheme,
                            accent: settingsState.accentColor
                        )
                    )

                    Button("Delete Item") {
                        deleteItem()
                        dismiss()
                    }
                    .foregroundColor(.red)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.clear)
        }
        .navigationTitle("Edit Item")
        .navigationBarTitleDisplayMode(.inline)
    }

    func formatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    func saveItem() {
        // Update name, quantity, unit
        itemState.updateItem(
            item,
            name: name,
            quantity: quantity,
            unit: unit
        )

        // Update expiration + category
        if let index = itemState.items.firstIndex(where: { $0.id == item.id }) {
            itemState.items[index].expirationDate = expirationDate
            itemState.items[index].category = category
            itemState.items[index].quantityType = unit.rawValue
        }

        // Persistence happens automatically via ItemState.didSet
    }

    func deleteItem() {
        itemState.removeItem(item, alertState: alertState)
        // Persistence happens automatically via ItemState.didSet
    }
}
