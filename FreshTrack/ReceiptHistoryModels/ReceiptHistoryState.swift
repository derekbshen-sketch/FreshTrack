//
//  ReceiptHistoryState.swift
//  FreshTrack
//

import Foundation
import SwiftUI
import Combine

class ReceiptHistoryState: ObservableObject {
    @Published var history: [ReceiptHistoryItem] = [] {
        didSet { PersistenceManager.shared.saveReceiptHistory(history) }
    }

    init() {
        self.history = PersistenceManager.shared.loadReceiptHistory()
    }

    func addReceipt(items: [ScannedItem], image: UIImage?) {
        let imageData = image?.jpegData(compressionQuality: 0.7)

        let entry = ReceiptHistoryItem(
            dateScanned: Date(),
            items: items,
            imageData: imageData
        )

        history.append(entry)
    }

    func clearHistory() {
        history.removeAll()
    }
}
