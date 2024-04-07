//
//  PomodoroTimer.swift
//  menubarApp
//
//  Created by Ganeshlingam C on 01/04/23.
//

import Foundation

protocol PomodoroTimerDelegate: AnyObject {
    func pomodoroTimer(_ timer: PomodoroTimer, didUpdateRemainingTime remainingTime: TimeInterval)
    func pomodoroTimerDidFinish(_ timer: PomodoroTimer)
}

class PomodoroTimer {
    weak var delegate: PomodoroTimerDelegate?
    private(set) var duration: TimeInterval
    private var remainingTime: TimeInterval
    private var timer: Timer?
    private var isPaused = false

    init(duration: TimeInterval) {
        self.duration = duration
        self.remainingTime = duration
    }

    func start() {
        // Create and start timer
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            // Update remaining time and call delegate method
            self?.remainingTime -= 1
            self?.delegate?.pomodoroTimer(self!, didUpdateRemainingTime: self!.remainingTime)

            // Stop timer when time runs out
            if self?.remainingTime ?? 0 <= 0 {
                self?.stop()
                self?.delegate?.pomodoroTimerDidFinish(self!)
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
        } else {
            self.isPaused = false
            self.start()
        }
    }
}
