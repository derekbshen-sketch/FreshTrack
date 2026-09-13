//
//  ExpiringItemRow.swift
//  FreshTrack
//
//  Created by Derek Shen on 7/27/26.
//

import SwiftUI
import Foundation

struct ExpiringItemRow: View {
    let item: String
    let daysLeft: Int

    var body: some View {
        HStack {
            Text("\(item): Expires in \(daysLeft) days")
                .font(.body)
            Spacer()
        }
    }
}
