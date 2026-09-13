//
//  ExpiredItemHistoryState.swift
//  FreshTrack
//
//  Created by Derek Shen on 8/3/26.
//

import Foundation
import Combine

class ExpiredItemHistoryState: ObservableObject {
    @Published var history: [ExpiredItemHistoryItem] = []

    func addExpiredItem(_ item: Item) {
        let entry = ExpiredItemHistoryItem(
            dateExpired: Date(),
            item: item
        )
        history.append(entry)
    }

    func clearHistory() {
        history.removeAll()
    }
}

