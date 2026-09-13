//
//  ExpirationPickerView.swift
//  FreshTrack
//
//  Created by Derek Shen on 7/29/26.
//

import SwiftUI

struct ExpirationPickerView: View {
    @EnvironmentObject var settingsState: SettingsState
    @Environment(\.dismiss) var dismiss

    @State private var expirationDate: Date
    let onSave: (Date) -> Void

    init(initialDate: Date = Date(), onSave: @escaping (Date) -> Void) {
        self._expirationDate = State(initialValue: initialDate)
        self.onSave = onSave
    }

    var body: some View {

        // ⭐ FULL SCREEN THEME BACKGROUND
        ZStack {
            appBackground(for: settingsState.selectedTheme)
                .ignoresSafeArea()

            VStack(spacing: 24) {

                Text("Select Expiration Date")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(
                        themedAccent(
                            for: settingsState.selectedTheme,
                            accent: settingsState.accentColor
                        )
                    )
                    .padding(.top, 20)

                // Calendar-style date picker
                DatePicker(
                    "Expiration Date",
                    selection: $expirationDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .padding(.horizontal)

                // Quick-select buttons
                VStack(spacing: 12) {
                    Text("Quick Options")
                        .font(.headline)
                        .foregroundColor(themedTextColor(for: settingsState.selectedTheme))

                    HStack(spacing: 12) {
                        quickButton("Today", days: 0)
                        quickButton("+3 Days", days: 3)
                        quickButton("+7 Days", days: 7)
                        quickButton("+14 Days", days: 14)
                    }
                }

                Spacer()

                Button {
                    onSave(expirationDate)
                    dismiss()
                } label: {
                    Text("Save Date")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(settingsState.accentColor)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
        .navigationTitle("Expiration Date")
        .navigationBarTitleDisplayMode(.inline)
    }

    // Quick-select helper
    private func quickButton(_ title: String, days: Int) -> some View {
        Button {
            expirationDate = Calendar.current.date(byAdding: .day, value: days, to: Date()) ?? Date()
        } label: {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.white)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(settingsState.accentColor.opacity(0.8))
                .cornerRadius(8)
        }
    }
}

