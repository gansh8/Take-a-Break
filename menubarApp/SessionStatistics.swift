//
//  SessionStatistics.swift
//  menubarApp
//
//  Created by Claude on 27/12/25.
//

import Foundation

class SessionStatistics: ObservableObject {
    static let shared = SessionStatistics()

    @Published private(set) var todaySessionCount: Int = 0
    @Published private(set) var totalSessionCount: Int = 0
    @Published private(set) var currentStreak: Int = 0
    @Published private(set) var longestStreak: Int = 0

    private let todayKey = "TodaySessionCount"
    private let todayDateKey = "TodayDate"
    private let totalKey = "TotalSessionCount"
    private let currentStreakKey = "CurrentStreak"
    private let longestStreakKey = "LongestStreak"
    private let lastSessionDateKey = "LastSessionDate"

    private init() {
        loadStatistics()
        checkAndResetDaily()
    }

    func recordSessionComplete() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Update counts
        todaySessionCount += 1
        totalSessionCount += 1

        // Update streak
        if let lastSessionDate = UserDefaults.standard.object(forKey: lastSessionDateKey) as? Date {
            let lastSessionDay = calendar.startOfDay(for: lastSessionDate)
            let daysDiff = calendar.dateComponents([.day], from: lastSessionDay, to: today).day ?? 0

            if daysDiff == 0 {
                // Same day, streak continues
            } else if daysDiff == 1 {
                // Consecutive day, increment streak
                currentStreak += 1
                if currentStreak > longestStreak {
                    longestStreak = currentStreak
                }
            } else {
                // Streak broken
                currentStreak = 1
            }
        } else {
            // First session ever
            currentStreak = 1
            longestStreak = 1
        }

        // Save
        UserDefaults.standard.set(todaySessionCount, forKey: todayKey)
        UserDefaults.standard.set(totalSessionCount, forKey: totalKey)
        UserDefaults.standard.set(currentStreak, forKey: currentStreakKey)
        UserDefaults.standard.set(longestStreak, forKey: longestStreakKey)
        UserDefaults.standard.set(Date(), forKey: lastSessionDateKey)
        UserDefaults.standard.set(today, forKey: todayDateKey)

        // Post notification for UI updates
        NotificationCenter.default.post(name: .sessionCompleted, object: self)
    }

    private func loadStatistics() {
        todaySessionCount = UserDefaults.standard.integer(forKey: todayKey)
        totalSessionCount = UserDefaults.standard.integer(forKey: totalKey)
        currentStreak = UserDefaults.standard.integer(forKey: currentStreakKey)
        longestStreak = UserDefaults.standard.integer(forKey: longestStreakKey)
    }

    private func checkAndResetDaily() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        if let savedDate = UserDefaults.standard.object(forKey: todayDateKey) as? Date {
            let savedDay = calendar.startOfDay(for: savedDate)
            if today != savedDay {
                // New day, reset today's count
                todaySessionCount = 0
                UserDefaults.standard.set(0, forKey: todayKey)
                UserDefaults.standard.set(today, forKey: todayDateKey)
            }
        } else {
            // First time running
            UserDefaults.standard.set(today, forKey: todayDateKey)
        }
    }

    func resetStatistics() {
        todaySessionCount = 0
        totalSessionCount = 0
        currentStreak = 0
        longestStreak = 0

        UserDefaults.standard.removeObject(forKey: todayKey)
        UserDefaults.standard.removeObject(forKey: totalKey)
        UserDefaults.standard.removeObject(forKey: currentStreakKey)
        UserDefaults.standard.removeObject(forKey: longestStreakKey)
        UserDefaults.standard.removeObject(forKey: lastSessionDateKey)
        UserDefaults.standard.removeObject(forKey: todayDateKey)
    }
}

extension Notification.Name {
    static let sessionCompleted = Notification.Name("sessionCompleted")
}
