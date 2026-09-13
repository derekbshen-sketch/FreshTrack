//
//  AddItemView.swift
//  FreshTrack
//

import SwiftUI

struct AddItemView: View {
    @EnvironmentObject var itemState: ItemState
    @EnvironmentObject var settingsState: SettingsState
    @EnvironmentObject var alertState: AlertState
    @EnvironmentObject var statisticsState: StatisticsState
    @EnvironmentObject var budgetState: BudgetState
    @Environment(\.dismiss) var dismiss

    @State private var name: String = ""
    @State private var category: String = "Pantry"
    @State private var quantity: Double = 1
    @State private var unit: QuantityUnit = .items
    @State private var expirationDate: Date = Date()

    @State private var costInput: String = ""
    @State private var cost: Double? = nil

    @State private var showError: Bool = false

    let categories = ["Pantry", "Fridge", "Freezer"]

    var body: some View {

        // ⭐ FULL SCREEN THEME BACKGROUND
        ZStack {
            appBackground(for: settingsState.selectedTheme)
                .ignoresSafeArea()

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
                                Text(u.rawValue.capitalized).tag(u)
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
                        Text("Please fill out all required fields.")
                            .foregroundColor(.red)
                    }
                }

                Section {
                    Button("Add Item") {
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
        }
        .navigationTitle("Add Item")
        .navigationBarTitleDisplayMode(.inline)
    }

    func formatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    func addItem() {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            showError = true
            return
        }

        let newItem = Item(
            name: name,
            category: category,
            expirationDate: expirationDate,
            quantity: quantity,
            quantityType: unit.rawValue,
            cost: cost
        )

        itemState.addItem(newItem, settingsState: settingsState, alertState: alertState)

        if let c = cost {
            statisticsState.addSpending(itemName: name, amount: c)
            budgetState.weeklyBudget -= c
        }

        dismiss()
    }
}
