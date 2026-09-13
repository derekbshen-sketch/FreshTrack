//
//  PantryView.swift
//  FreshTrack
//
//  Created by Derek Shen on 8/4/26.
//

import SwiftUI
import Foundation
import Combine

struct PantryView: View {
    @EnvironmentObject var itemState: ItemState
    @EnvironmentObject var settingsState: SettingsState
    @EnvironmentObject var alertState: AlertState

    @State private var selectedItem: Item?

    var pantryItems: [Item] {
        itemState.items.filter { $0.category.lowercased() == "pantry" }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // HEADER
            Text("Pantry")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(
                    themedAccent(
                        for: settingsState.selectedTheme,
                        accent: settingsState.accentColor
                    )
                )

            GeometryReader { geo in
                ZStack {

                    // WOODEN CABINET BODY
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.55, green: 0.35, blue: 0.20),
                                    Color(red: 0.45, green: 0.28, blue: 0.15)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.black.opacity(0.3), lineWidth: 3)
                        )
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 6)

                    // WOOD GRAIN OVERLAY
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.05),
                                    Color.black.opacity(0.1)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )

                    // REALISTIC SHELVES
                    ForEach(0..<3) { i in
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.45, green: 0.28, blue: 0.15),
                                        Color(red: 0.35, green: 0.22, blue: 0.12)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(height: 12)
                            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 3)
                            .offset(y: -geo.size.height * 0.3 + CGFloat(i) * (geo.size.height * 0.3))
                    }

                    // ITEMS WITH PERSISTENT POSITIONS + DRAG
                    ForEach(pantryItems, id: \.id) { item in
                        let x = item.posX * geo.size.width
                        let y = item.posY * geo.size.height

                        FoodTile(item: item)
                            .position(x: x, y: y)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        let newX = value.location.x / geo.size.width
                                        let newY = value.location.y / geo.size.height

                                        itemState.updatePosition(
                                            item,
                                            x: min(max(newX, 0.05), 0.95),
                                            y: min(max(newY, 0.05), 0.95)
                                        )
                                    }
                            )
                            .onTapGesture {
                                selectedItem = item
                            }
                    }
                }
            }
            .frame(height: 300)

            // INLINE EDITOR
            if let editing = selectedItem {
                ItemInlineEditor(
                    item: editing,
                    onDelete: {
                        itemState.removeItem(editing, alertState: alertState)
                        selectedItem = nil
                    },
                    onSave: { updatedName, updatedQty, updatedUnit, updatedCategory, updatedExpiration in

                        // Update name, quantity, unit
                        itemState.updateItem(
                            editing,
                            name: updatedName,
                            quantity: updatedQty,
                            unit: updatedUnit
                        )

                        // Update category, expiration, cost
                        if let index = itemState.items.firstIndex(where: { $0.id == editing.id }) {
                            itemState.items[index].category = updatedCategory
                            itemState.items[index].expirationDate = updatedExpiration
                        }

                        selectedItem = nil
                    }
                )
                .environmentObject(settingsState)
                .padding(.top, 12)
            }
        }
        .padding(.horizontal)
    }
}
