//
//  AlertState.swift
//  FreshTrack
//

import SwiftUI
import UserNotifications
import Combine

class AlertState: ObservableObject {
    @Published var alerts: [AlertItem] = [] {
        didSet { PersistenceManager.shared.saveAlerts(alerts) }
    }

    init() {
        self.alerts = PersistenceManager.shared.loadAlerts()
    }

    // MARK: - Manual Alert
    func addManualAlert(title: String, date: Date, time: Date) {
        let notificationID = UUID().uuidString
        let combined = combine(date: date, time: time)

        let alert = AlertItem(
            itemID: nil,
            notificationID: notificationID,
            title: title.isEmpty ? "FreshTrack Alert" : title,
            alertDate: date,
            alertTime: time,
            expirationDate: nil
        )

        alerts.append(alert)
        sortAlerts()

        NotificationManager.shared.scheduleNotification(
            id: notificationID,
            title: alert.title,
            body: alert.title,
            date: combined
        )
    }

    // MARK: - Item Alert
    func addAlert(
        for item: Item,
        title: String,
        date: Date,
        time: Date,
        expirationDate: Date? = nil
    ) {
        let notificationID = UUID().uuidString
        let combined = combine(date: date, time: time)

        let alert = AlertItem(
            itemID: item.id,
            notificationID: notificationID,
            title: title.isEmpty ? "FreshTrack Alert" : title,
            alertDate: date,
            alertTime: time,
            expirationDate: expirationDate ?? item.expirationDate
        )

        alerts.append(alert)
        sortAlerts()

        NotificationManager.shared.scheduleNotification(
            id: notificationID,
            title: alert.title,
            body: "\(item.name) expires on \(formatted(alert.expirationDate))",
            date: combined
        )
    }

    // MARK: - Auto Alert
    func addAutoAlert(for item: Item, settings: SettingsState) {
        let calendar = Calendar.current
        let expiration = calendar.startOfDay(for: item.expirationDate)

        guard let alertDate = calendar.date(
            byAdding: .day,
            value: -settings.expirationAlertDaysBefore,
            to: expiration
        ) else { return }

        let alertTime = calendar.date(
            bySettingHour: calendar.component(.hour, from: settings.expirationAlertTime),
            minute: calendar.component(.minute, from: settings.expirationAlertTime),
            second: 0,
            of: alertDate
        ) ?? alertDate

        let daysUntil = item.daysUntilExpiration
        let title: String

        switch daysUntil {
        case let d where d > 1:
            title = "\(item.name) expires in \(d) days"
        case 1:
            title = "\(item.name) expires tomorrow"
        case 0:
            title = "\(item.name) expires today"
        default:
            title = "\(item.name) expired \(-daysUntil) days ago"
        }

        addAlert(
            for: item,
            title: title,
            date: alertDate,
            time: alertTime,
            expirationDate: item.expirationDate
        )
    }

    // MARK: - Delete Single Alert
    func deleteAlert(_ alert: AlertItem) {
        NotificationManager.shared.cancelNotification(id: alert.notificationID)
        alerts.removeAll { $0.id == alert.id }
        sortAlerts()
    }

    // MARK: - Delete Alerts for Item
    func deleteAlerts(for item: Item) {
        let ids = alerts
            .filter { $0.itemID == item.id }
            .map { $0.notificationID }

        NotificationManager.shared.cancelNotifications(ids: ids)
        alerts.removeAll { $0.itemID == item.id }
        sortAlerts()
    }

    // MARK: - Update Alert
    func updateAlert(_ alert: AlertItem, title: String, date: Date, time: Date) {
        guard let index = alerts.firstIndex(where: { $0.id == alert.id }) else { return }

        let combined = combine(date: date, time: time)

        alerts[index] = AlertItem(
            id: alert.id,
            itemID: alert.itemID,
            notificationID: alert.notificationID,
            title: title.isEmpty ? "FreshTrack Alert" : title,
            alertDate: date,
            alertTime: time,
            expirationDate: alert.expirationDate
        )

        NotificationManager.shared.cancelNotification(id: alert.notificationID)

        NotificationManager.shared.scheduleNotification(
            id: alert.notificationID,
            title: alerts[index].title,
            body: alerts[index].title,
            date: combined
        )

        sortAlerts()
    }

    func sortAlerts() {
        alerts.sort { $0.alertDate < $1.alertDate }
    }

    private func combine(date: Date, time: Date) -> Date {
        let calendar = Calendar.current
        let d = calendar.dateComponents([.year, .month, .day], from: date)
        let t = calendar.dateComponents([.hour, .minute], from: time)

        return calendar.date(from: DateComponents(
            year: d.year,
            month: d.month,
            day: d.day,
            hour: t.hour,
            minute: t.minute
        )) ?? date
    }

    private func formatted(_ date: Date?) -> String {
        guard let date = date else { return "Unknown date" }
        let f = DateFormatter()
        f.dateStyle = .medium
        return f.string(from: date)
    }
}
