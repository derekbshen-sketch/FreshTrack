//
//  BudgetState.swift
//  FreshTrack
//

import Foundation
import Combine
import UserNotifications

class BudgetState: ObservableObject {
    @Published var weeklyBudget: Double = 75 { didSet { save() } }
    @Published var monthlyBudget: Double = 300 { didSet { save() } }
    @Published var yearlyBudget: Double = 3600 { didSet { save() } }

    @Published var alertsEnabled: Bool = true { didSet { save() } }
    @Published var weeklySummaryEnabled: Bool = true { didSet { save() } }

    @Published var alertTime: Date = Calendar.current.date(
        bySettingHour: 9, minute: 0, second: 0, of: Date()
    )! { didSet { save() } }

    init() {
        if let loaded = PersistenceManager.shared.loadBudget() {
            self.weeklyBudget = loaded.weeklyBudget
            self.monthlyBudget = loaded.monthlyBudget
            self.yearlyBudget = loaded.yearlyBudget
            self.alertsEnabled = loaded.alertsEnabled
            self.weeklySummaryEnabled = loaded.weeklySummaryEnabled
            self.alertTime = loaded.alertTime
        }
    }

    func save() {
        let codable = BudgetStateCodable(
            weeklyBudget: weeklyBudget,
            monthlyBudget: monthlyBudget,
            yearlyBudget: yearlyBudget,
            alertsEnabled: alertsEnabled,
            weeklySummaryEnabled: weeklySummaryEnabled,
            alertTime: alertTime
        )

        PersistenceManager.shared.saveBudget(codable)
    }

    func evaluateOverspending(with statistics: StatisticsState) {
        guard alertsEnabled else { return }

        let weeklySpending = statistics.weeklySpending()
        let monthlySpending = statistics.monthlySpending()

        if weeklySpending > weeklyBudget {
            let over = weeklySpending - weeklyBudget
            sendNotification(
                title: "Weekly Budget Exceeded",
                body: "You spent $\(weeklySpending.cleanString()) this week, $\(over.cleanString()) over budget."
            )
        }

        if monthlySpending > monthlyBudget {
            let over = monthlySpending - monthlyBudget
            sendNotification(
                title: "Monthly Budget Exceeded",
                body: "You spent $\(monthlySpending.cleanString()) this month, $\(over.cleanString()) over budget."
            )
        }
    }

    func scheduleWeeklySummary(with statistics: StatisticsState) {
        guard weeklySummaryEnabled else { return }

        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["weeklySummaryBudget"])

        var components = Calendar.current.dateComponents([.weekday, .hour, .minute], from: alertTime)
        components.weekday = 1 // Sunday

        let weeklySpending = statistics.weeklySpending()
        let diff = weeklySpending - weeklyBudget

        let body: String
        if diff > 0 {
            body = "You spent $\(weeklySpending.cleanString()) this week, $\(diff.cleanString()) over budget."
        } else {
            body = "You spent $\(weeklySpending.cleanString()) this week, $\((-diff).cleanString()) under budget."
        }

        let content = UNMutableNotificationContent()
        content.title = "Weekly Grocery Summary"
        content.body = body
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        let request = UNNotificationRequest(
            identifier: "weeklySummaryBudget",
            content: content,
            trigger: trigger
        )

        center.add(request, withCompletionHandler: nil)
    }

    private func sendNotification(title: String, body: String) {
        let center = UNUserNotificationCenter.current()

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )

        center.add(request, withCompletionHandler: nil)
    }
}

struct BudgetStateCodable: Codable {
    var weeklyBudget: Double
    var monthlyBudget: Double
    var yearlyBudget: Double
    var alertsEnabled: Bool
    var weeklySummaryEnabled: Bool
    var alertTime: Date
}
