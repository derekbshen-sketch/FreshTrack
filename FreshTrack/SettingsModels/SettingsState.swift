//
//  SettingsState.swift
//  FreshTrack
//
import SwiftUI
import Combine

// MARK: - Color <-> Hex Support
extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255
        let b = CGFloat(rgb & 0x0000FF) / 255

        self.init(red: r, green: g, blue: b, alpha: 1)
    }

    func toHexString() -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0

        getRed(&r, green: &g, blue: &b, alpha: &a)

        return String(format: "#%02lX%02lX%02lX",
                      Int(r * 255),
                      Int(g * 255),
                      Int(b * 255))
    }
}

extension Color {
    func toHex() -> String {
        UIColor(self).toHexString()
    }

    static func fromHex(_ hex: String) -> Color {
        Color(UIColor(hex: hex))
    }
}

// MARK: - AppTheme (must be Codable)
enum AppTheme: String, CaseIterable, Identifiable, Codable {
    case light
    case dark
    case aurora
    case sunset
    case ocean
    case forest
    case minimalWhite
    case highContrast
    case warm
    case cool

    var id: String { rawValue }
}

// MARK: - SettingsState (ObservableObject)
class SettingsState: ObservableObject {

    @Published var darkMode: Bool = false { didSet { save() } }

    // ⭐ Accent color now persists
    @Published var accentColor: Color = .purple { didSet { save() } }

    @Published var notificationsEnabled: Bool = true { didSet { save() } }
    @Published var autoExpirationAlerts: Bool = true { didSet { save() } }
    @Published var selectedTheme: AppTheme = .light { didSet { save() } }

    @Published var expirationAlertDaysBefore: Int = 1 { didSet { save() } }
    @Published var expirationAlertTime: Date = Calendar.current.date(
        bySettingHour: 9, minute: 0, second: 0, of: Date()
    )! { didSet { save() } }

    @Published var keepDeletedItemsInHistory: Bool = true { didSet { save() } }

    // MARK: - Init (load saved settings)
    init() {
        if let loaded = PersistenceManager.shared.loadSettings() {
            self.darkMode = loaded.darkMode
            self.notificationsEnabled = loaded.notificationsEnabled
            self.autoExpirationAlerts = loaded.autoExpirationAlerts
            self.selectedTheme = loaded.selectedTheme
            self.expirationAlertDaysBefore = loaded.expirationAlertDaysBefore
            self.expirationAlertTime = loaded.expirationAlertTime
            self.keepDeletedItemsInHistory = loaded.keepDeletedItemsInHistory

            // ⭐ Load accent color
            self.accentColor = Color.fromHex(loaded.accentColorHex)
        }
    }

    // MARK: - Save
    func save() {
        let codable = SettingsStateCodable(
            darkMode: darkMode,
            notificationsEnabled: notificationsEnabled,
            autoExpirationAlerts: autoExpirationAlerts,
            selectedTheme: selectedTheme,
            expirationAlertDaysBefore: expirationAlertDaysBefore,
            expirationAlertTime: expirationAlertTime,
            keepDeletedItemsInHistory: keepDeletedItemsInHistory,
            accentColorHex: accentColor.toHex()   // ⭐ Save accent color
        )

        PersistenceManager.shared.saveSettings(codable)
    }
}

// MARK: - Codable Mirror (only codable properties)
struct SettingsStateCodable: Codable {
    var darkMode: Bool
    var notificationsEnabled: Bool
    var autoExpirationAlerts: Bool
    var selectedTheme: AppTheme
    var expirationAlertDaysBefore: Int
    var expirationAlertTime: Date
    var keepDeletedItemsInHistory: Bool

    // ⭐ Accent color now included
    var accentColorHex: String
}
