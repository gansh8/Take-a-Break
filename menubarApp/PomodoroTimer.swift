//
//  PomodoroTimer.swift
//  menubarApp
//
//  Created by Ganeshlingam C on 01/04/23.
//

import Foundation
import Combine

protocol PomodoroTimerDelegate: AnyObject {
    func pomodoroTimer(_ timer: PomodoroTimer, didUpdateRemainingTime remainingTime: TimeInterval)
    func pomodoroTimerDidFinish(_ timer: PomodoroTimer)
}

class PomodoroTimer: ObservableObject {
    weak var delegate: PomodoroTimerDelegate?
    private(set) var duration: TimeInterval
    private var remainingTime: TimeInterval
    private var timer: Timer?
    private var isPaused = false
    private var lastSaveTime: Date?

    init(duration: TimeInterval) {
        self.duration = duration
        self.remainingTime = duration
        restoreState()
    }

    func start() {
        // Create and start timer
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            // Update remaining time and call delegate method
            self.remainingTime -= 1
            self.delegate?.pomodoroTimer(self, didUpdateRemainingTime: self.remainingTime)

            // Post notification for SwiftUI views
            NotificationCenter.default.post(
                name: .pomodoroTimerUpdate,
                object: self,
                userInfo: [
                    "remainingTime": self.remainingTime,
                    "duration": self.duration
                ]
            )

            // Save state every 5 seconds to avoid excessive writes
            if Int(self.remainingTime) % 5 == 0 {
                self.saveState()
            }

            // Stop timer when time runs out
            if self.remainingTime <= 0 {
                self.stop()
                self.delegate?.pomodoroTimerDidFinish(self)
                NotificationCenter.default.post(name: .pomodoroTimerFinished, object: self)
            }
        }
    }

    func stop() {
        // Stop and reset timer
        timer?.invalidate()
        timer = nil
        remainingTime = duration
    }

    func pause() {
        if !self.isPaused {
            self.isPaused = true
            timer?.invalidate()
            timer = nil
            saveState()
        } else {
            self.isPaused = false
            self.start()
        }
        NotificationCenter.default.post(
            name: .pomodoroTimerPausedChanged,
            object: self,
            userInfo: ["isPaused": self.isPaused]
        )
    }
    
    func pauseForIdle() {
        if !self.isPaused {
            self.isPaused = true
            timer?.invalidate()
            timer = nil
        }
    }
    
    func resumeFromIdle() {
        if self.isPaused {
            self.isPaused = false
            self.start()
        }
    }
    
    var isTimerPaused: Bool {
        return isPaused
    }

    // MARK: - Timer Persistence
    private func saveState() {
        UserDefaults.standard.set(remainingTime, forKey: "TimerRemainingTime")
        UserDefaults.standard.set(isPaused, forKey: "TimerIsPaused")
        UserDefaults.standard.set(Date(), forKey: "TimerLastSaveTime")
    }

    private func restoreState() {
        guard let lastSave = UserDefaults.standard.object(forKey: "TimerLastSaveTime") as? Date else {
            return
        }

        let savedRemainingTime = UserDefaults.standard.double(forKey: "TimerRemainingTime")
        let wasPaused = UserDefaults.standard.bool(forKey: "TimerIsPaused")

        // Only restore if saved within last 24 hours
        let timeSinceSave = Date().timeIntervalSince(lastSave)
        guard timeSinceSave < 86400 else {
            clearSavedState()
            return
        }

        if wasPaused {
            // If timer was paused, restore exact remaining time
            remainingTime = savedRemainingTime
            isPaused = true
        } else {
            // If timer was running, account for elapsed time
            let adjustedRemainingTime = savedRemainingTime - timeSinceSave
            if adjustedRemainingTime > 0 {
                remainingTime = adjustedRemainingTime
            } else {
                // Timer would have finished while app was closed
                remainingTime = duration
            }
        }
    }

    private func clearSavedState() {
        UserDefaults.standard.removeObject(forKey: "TimerRemainingTime")
        UserDefaults.standard.removeObject(forKey: "TimerIsPaused")
        UserDefaults.standard.removeObject(forKey: "TimerLastSaveTime")
    }
}
