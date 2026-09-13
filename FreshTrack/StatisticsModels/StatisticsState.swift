//
//  StatisticsState.swift
//  FreshTrack
//

import Foundation
import Combine
import Charts

class StatisticsState: ObservableObject {
    @Published var entries: [SpendingEntry] = [] {
        didSet { PersistenceManager.shared.saveStatistics(entries) }
    }

    init() {
        self.entries = PersistenceManager.shared.loadStatistics()
    }

    func addSpending(itemName: String? = nil, amount: Double?, date: Date = Date()) {
        guard let amount = amount, amount > 0 else { return }
        let entry = SpendingEntry(itemName: itemName, amount: amount, date: date)
        entries.append(entry)
    }

    func syncFromItems(_ items: [Item]) {
        for item in items {
            if let cost = item.cost, cost > 0 {
                addSpending(itemName: item.name, amount: cost, date: item.dateAdded)
            }
        }
    }

    func total(in interval: DateInterval) -> Double {
        entries
            .filter { interval.contains($0.date) }
            .map { $0.amount }
            .reduce(0, +)
    }

    func weeklySpending() -> Double {
        let calendar = Calendar.current
        let now = Date()
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
        let endOfWeek = calendar.date(byAdding: .day, value: 7, to: startOfWeek)!
        return total(in: DateInterval(start: startOfWeek, end: endOfWeek))
    }

    func monthlySpending() -> Double {
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        let endOfMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth)!
        return total(in: DateInterval(start: startOfMonth, end: endOfMonth))
    }

    func yearlySpending() -> Double {
        let calendar = Calendar.current
        let now = Date()
        let startOfYear = calendar.date(from: calendar.dateComponents([.year], from: now))!
        let endOfYear = calendar.date(byAdding: .year, value: 1, to: startOfYear)!
        return total(in: DateInterval(start: startOfYear, end: endOfYear))
    }

    func weeklyDifference(from budget: Double) -> Double {
        weeklySpending() - budget
    }

    func monthlyDifference(from budget: Double) -> Double {
        monthlySpending() - budget
    }

    func yearlyDifference(from budget: Double) -> Double {
        yearlySpending() - budget
    }

    func topItems(limit: Int = 5) -> [ItemSpendingSummary] {
        let grouped = Dictionary(grouping: entries.compactMap { $0.itemName }) { $0.lowercased() }

        let summaries = grouped.map { key, names -> ItemSpendingSummary in
            let total = entries
                .filter { $0.itemName?.lowercased() == key }
                .map { $0.amount }
                .reduce(0, +)

            let displayName = names.first ?? key
            let count = entries.filter { $0.itemName?.lowercased() == key }.count

            return ItemSpendingSummary(name: displayName, total: total, count: count)
        }

        return summaries
            .sorted { $0.total > $1.total }
            .prefix(limit)
            .map { $0 }
    }
}

extension StatisticsState {

    func weeklyData() -> [(date: Date, amount: Double)] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        return (0..<7).map { offset in
            let day = calendar.date(byAdding: .day, value: -offset, to: today)!
            let total = entries
                .filter { calendar.isDate($0.date, inSameDayAs: day) }
                .map { $0.amount }
                .reduce(0, +)
            return (day, total)
        }
        .sorted { $0.date < $1.date }
    }

    func monthlyData() -> [(date: Date, amount: Double)] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        return (0..<30).map { offset in
            let day = calendar.date(byAdding: .day, value: -offset, to: today)!
            let total = entries
                .filter { calendar.isDate($0.date, inSameDayAs: day) }
                .map { $0.amount }
                .reduce(0, +)
            return (day, total)
        }
        .sorted { $0.date < $1.date }
    }

    func yearlyData() -> [(date: Date, amount: Double)] {
        let calendar = Calendar.current
        let now = Date()

        return (0..<12).map { offset in
            let month = calendar.date(byAdding: .month, value: -offset, to: now)!
            let comps = calendar.dateComponents([.year, .month], from: month)
            let start = calendar.date(from: comps)!
            let end = calendar.date(byAdding: .month, value: 1, to: start)!

            let total = entries
                .filter { $0.date >= start && $0.date < end }
                .map { $0.amount }
                .reduce(0, +)

            return (start, total)
        }
        .sorted { $0.date < $1.date }
    }
}
