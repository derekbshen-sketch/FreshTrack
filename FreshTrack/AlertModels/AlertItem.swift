//
//  AlertItem.swift
//  FreshTrack
//

import Foundation

struct AlertItem: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var itemID: UUID?              // nil for manual alerts, set for auto/item alerts
    var notificationID: String

    var title: String
    var alertDate: Date
    var alertTime: Date
    var expirationDate: Date?      // nil for manual alerts, set for auto/item alerts

    var formattedDate: String {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f.string(from: alertDate)
    }

    var formattedTime: String {
        let f = DateFormatter()
        f.timeStyle = .short
        return f.string(from: alertTime)
    }
}
