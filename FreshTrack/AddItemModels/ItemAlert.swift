//
//  ItemAlert.swift
//  FreshTrack
//
//  Created by Derek Shen on 8/6/26.
//

import Foundation

struct ItemAlert: Identifiable, Codable {
    var id: UUID
    var itemID: UUID
    var title: String
    var alertDate: Date
    var expirationDate: Date
}
