//
//  ReceiptHistoryItem.swift
//  FreshTrack
//
//  Created by Derek Shen on 7/30/26.
//

import Foundation
import UIKit

struct ReceiptHistoryItem: Identifiable, Codable {
    let id: UUID
    let dateScanned: Date
    let items: [ScannedItem]
    let imageData: Data?   // store receipt image

    init(
        id: UUID = UUID(),
        dateScanned: Date,
        items: [ScannedItem],
        imageData: Data?
    ) {
        self.id = id
        self.dateScanned = dateScanned
        self.items = items
        self.imageData = imageData
    }
}
