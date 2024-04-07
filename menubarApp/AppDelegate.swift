//
//  AppDelegate.swift
//  menubarApp
//
//  Created by Ganeshlingam C on 01/04/23.
//

import Cocoa
import UserNotifications

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var pomodoroTimer: PomodoroTimer!
    var timerViewController: TimerViewController!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.image = NSImage(systemSymbolName: "clock", accessibilityDescription: nil)
        statusItem.button?.title = "25:00"
        statusItem.button?.target = self
        statusItem.button?.action = #selector(statusItemClicked)

        // Create and start Pomodoro timer
        pomodoroTimer = PomodoroTimer(duration: TimeInterval(AppPreferences.shared.workTimeMins * 60))
        pomodoroTimer.delegate = self
        pomodoroTimer.start()

        timerViewController = TimerViewController(nibName: "TimerViewController", bundle: nil)
        timerViewController.timerDelegate = pomodoroTimer
        self.setDefaultPreferences()
    }

    @objc func statusItemClicked(sender: NSStatusBarButton) {
        timerViewController.togglePopover(statusItem.button!)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

    private func setDefaultPreferences() {
        UserDefaults.standard.register(defaults: [
            "ShowTimeInMenuBar": true,
            "BreakViewBackgroundColor": CGColor.black.components ?? [],
            "WorkTimeMins": 20,
            "BreakTimeSeconds": 20,
            "BreakMessage": "Take a Break.!"
        ])
    }
}

extension AppDelegate: PomodoroTimerDelegate {
    func pomodoroTimer(_ timer: PomodoroTimer, didUpdateRemainingTime remainingTime: TimeInterval) {
        // Update button title with remaining time
        let minutes = Int(remainingTime) / 60
        let seconds = Int(remainingTime) % 60
        if AppPreferences.shared.showTimeInMenuBar {
            statusItem.button?.title = String(format: "%02d:%02d", minutes, seconds)
        } else {
            statusItem.button?.title = ""
        }
        timerViewController.updateTimeLabel(String(format: "%02d:%02d", minutes, seconds))
        timerViewController.updateProgressIndicator(remainingTime / Double(timer.duration))
    }

    func pomodoroTimerDidFinish(_ timer: PomodoroTimer) {
        let center = UNUserNotificationCenter.current()

        let content = UNMutableNotificationContent()
        content.title = "Pomodoro Timer"
        content.body = "Time's up!"
        content.sound = UNNotificationSound.default

        let request = UNNotificationRequest(identifier: "pomodoroNotification", content: content, trigger: nil)
        center.add(request) { error in
            if let error = error {
                print("Error displaying notification: \(error.localizedDescription)")
            }
        }

        timerViewController.updateTimeLabel("25:00")
        timerViewController.updateProgressIndicator(1.0)
    }
}
