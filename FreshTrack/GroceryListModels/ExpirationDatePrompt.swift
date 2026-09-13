//
//  ExpirationDatePrompt.swift
//  FreshTrack
//
//  Created by Derek Shen on 8/3/26.
//

import SwiftUI

struct ExpirationDatePrompt: View {
    var item: Item
    var quantity: Double
    var unit: QuantityUnit

    @Binding var selectedDate: Date
    var onConfirm: (Date) -> Void

    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Set Expiration Date")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("For: \(item.name)")
                    .font(.headline)

                DatePicker(
                    "Expiration Date",
                    selection: $selectedDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .padding()

                Spacer()

                Button {
                    onConfirm(selectedDate)
                    dismiss()
                } label: {
                    Text("Confirm")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }

                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                        .foregroundColor(.red)
                        .padding(.top, 10)
                }

                Spacer()
            }
            .navigationTitle("Expiration Date")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
