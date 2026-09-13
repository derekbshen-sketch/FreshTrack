//
//  ItemInlineEditor.swift
//  FreshTrack
//
//  Created by Derek Shen on 8/5/26.
//

import Foundation
import Combine
import SwiftUI

struct ItemInlineEditor: View {
    @EnvironmentObject var settingsState: SettingsState

    @State var item: Item

    let onDelete: () -> Void
    let onSave: (
        String,          // name
        Double,          // quantity
        QuantityUnit,    // unit
        String,          // category
        Date             // expiration
    ) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            TextField("Item name", text: $item.name)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            VStack(alignment: .leading, spacing: 8) {
                Text("Quantity")
                    .foregroundColor(themedTextColor(for: settingsState.selectedTheme))

                TextField("Qty", value: $item.quantity, formatter: NumberFormatter())
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
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Unit")
                    .foregroundColor(themedTextColor(for: settingsState.selectedTheme))

                Picker("Unit", selection: Binding(
                    get: { QuantityUnit(rawValue: item.quantityType) ?? .items },
                    set: { item.quantityType = $0.rawValue }
                )) {
                    ForEach(QuantityUnit.allCases, id: \.self) { unit in
                        Text(unit.rawValue).tag(unit)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Category")
                    .foregroundColor(themedTextColor(for: settingsState.selectedTheme))

                Picker("Category", selection: $item.category) {
                    Text("Pantry").tag("Pantry")
                    Text("Fridge").tag("Fridge")
                    Text("Freezer").tag("Freezer")
                }
                .pickerStyle(SegmentedPickerStyle())
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Expiration Date")
                    .foregroundColor(themedTextColor(for: settingsState.selectedTheme))

                DatePicker("", selection: $item.expirationDate, displayedComponents: .date)
                    .datePickerStyle(.compact)
            }

            HStack {
                Button("Delete") {
                    onDelete()
                }
                .foregroundColor(.red)

                Spacer()

                Button("Save") {
                    onSave(
                        item.name,
                        item.quantity,
                        QuantityUnit(rawValue: item.quantityType) ?? .items,
                        item.category,
                        item.expirationDate
                    )
                }
                .foregroundColor(
                    themedAccent(
                        for: settingsState.selectedTheme,
                        accent: settingsState.accentColor
                    )
                )
            }
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.4))
        .cornerRadius(12)
    }
}
