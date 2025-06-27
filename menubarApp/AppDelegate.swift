//
//  AppDelegate.swift
//  menubarApp
//
//  Created by Ganeshlingam C on 01/04/23.
//

import Cocoa
import SwiftUI
import UserNotifications
import AVFoundation
import AudioToolbox
import ServiceManagement

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var pomodoroTimer: PomodoroTimer!
    var popover: NSPopover!
    var audioPlayer: AVAudioPlayer?
    
    // Status bar display management
    private enum StatusBarDisplayMode {
        case iconOnly
        case shortTime  // MM:SS
        case fullTime   // MM:SS with icon
    }
    private var currentDisplayMode: StatusBarDisplayMode = .fullTime
    
    // Mouse idle monitoring
    private var mouseIdleTimer: Timer?
    private var isMouseIdleMonitoringEnabled = false
    private var lastMousePosition: CGPoint = .zero
    private var lastActivityTime: TimeInterval = 0
    private var isCurrentlyIdle = false
    private let idleThreshold: TimeInterval = 30

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

        // Setup SwiftUI popover
        setupPopover()
        self.setDefaultPreferences()
        
        // Setup mouse idle monitoring
        lastActivityTime = Date().timeIntervalSince1970
        lastMousePosition = NSEvent.mouseLocation
        setMouseIdleMonitoring(enabled: AppPreferences.shared.pauseAtMouseIdle)
        
        // Setup notification observers
        NotificationCenter.default.addObserver(self, selector: #selector(handleLaunchAtStartupChange), name: .setLaunchAtStartup, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleMouseIdleMonitoringChange), name: .setMouseIdleMonitoring, object: nil)
    }

    @objc func statusItemClicked(sender: NSStatusBarButton) {
        togglePopover()
    }
    
    private func setupPopover() {
        popover = NSPopover()
        popover.contentSize = NSSize(width: 300, height: 406)
        popover.behavior = .transient
        
        let timerView = TimerView(pomodoroTimer: pomodoroTimer)
        popover.contentViewController = NSHostingController(rootView: timerView)
    }
    
    private func togglePopover() {
        if popover.isShown {
            popover.performClose(nil)
        } else {
            NSApplication.shared.activate(ignoringOtherApps: true)
            popover.show(relativeTo: statusItem.button!.bounds, of: statusItem.button!, preferredEdge: .minY)
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Cleanup notification observers
        NotificationCenter.default.removeObserver(self)
        
        // Stop mouse idle monitoring
        setMouseIdleMonitoring(enabled: false)
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
            "BreakMessage": "Take a Break.!",
            "LaunchAtStartup": false,
            "PlaySoundAtEnd": false,
            "FadeInBreak": false,
            "PauseAtMouseIdle": false,
            "EnableStandupBreak": false,
            "AdaptiveStatusBar": true
        ])
    }
}

extension AppDelegate: PomodoroTimerDelegate {
    func pomodoroTimer(_ timer: PomodoroTimer, didUpdateRemainingTime remainingTime: TimeInterval) {
        // Update button title with remaining time
        let minutes = Int(remainingTime) / 60
        let seconds = Int(remainingTime) % 60
        
        if AppPreferences.shared.showTimeInMenuBar {
            updateStatusBarDisplay(minutes: minutes, seconds: seconds)
        } else {
            statusItem.button?.title = ""
            statusItem.button?.image = NSImage(systemSymbolName: "clock", accessibilityDescription: nil)
        }
        // SwiftUI views are updated via notifications in PomodoroTimer
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
        
        // Play sound if enabled
        if AppPreferences.shared.playSoundAtEnd {
            playBreakEndSound()
        }

        // SwiftUI views are updated via notifications in PomodoroTimer
    }
    
    private func playBreakEndSound() {
        // Use system sound for break end
        let systemSoundID: SystemSoundID = 1016 // System sound for completion
        AudioServicesPlaySystemSound(systemSoundID)
    }
    
    @objc private func handleLaunchAtStartupChange(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let enabled = userInfo["enabled"] as? Bool {
            setLaunchAtStartup(enabled: enabled)
        }
    }
    
    @objc private func handleMouseIdleMonitoringChange(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let enabled = userInfo["enabled"] as? Bool {
            setMouseIdleMonitoring(enabled: enabled)
        }
    }
    
    // MARK: - Launch at startup functionality
    private func setLaunchAtStartup(enabled: Bool) {
        if #available(macOS 13.0, *) {
            do {
                if enabled {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
            } catch {
                print("Failed to \(enabled ? "enable" : "disable") launch at startup: \(error)")
            }
        } else {
            // Fallback for older macOS versions - simplified approach
            print("Launch at startup not fully supported on macOS < 13.0")
        }
    }
    
    // MARK: - Mouse idle monitoring functionality
    private func setMouseIdleMonitoring(enabled: Bool) {
        isMouseIdleMonitoringEnabled = enabled
        
        if enabled {
            startMouseIdleMonitoring()
        } else {
            stopMouseIdleMonitoring()
        }
    }
    
    private func startMouseIdleMonitoring() {
        stopMouseIdleMonitoring()
        
        mouseIdleTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.checkMouseActivity()
        }
    }
    
    private func stopMouseIdleMonitoring() {
        mouseIdleTimer?.invalidate()
        mouseIdleTimer = nil
        
        // Reset idle state when stopping
        if isCurrentlyIdle {
            isCurrentlyIdle = false
            pomodoroTimer.resumeFromIdle()
        }
    }
    
    private func checkMouseActivity() {
        let currentMousePosition = NSEvent.mouseLocation
        let currentTime = Date().timeIntervalSince1970
        
        // Check if mouse moved
        if currentMousePosition != lastMousePosition {
            lastMousePosition = currentMousePosition
            lastActivityTime = currentTime
            
            // If we were idle, notify that we're active again
            if isCurrentlyIdle {
                isCurrentlyIdle = false
                pomodoroTimer.resumeFromIdle()
            }
        } else {
            // Mouse hasn't moved, check if we've been idle long enough
            let timeSinceLastActivity = currentTime - lastActivityTime
            
            if timeSinceLastActivity >= idleThreshold && !isCurrentlyIdle {
                isCurrentlyIdle = true
                pomodoroTimer.pauseForIdle()
            }
        }
    }
    
    // MARK: - Status bar display management
    private func updateStatusBarDisplay(minutes: Int, seconds: Int) {
        let timeString = String(format: "%02d:%02d", minutes, seconds)
        
        // Check if adaptive display is enabled
        if AppPreferences.shared.adaptiveStatusBar {
            // Try different display modes based on available space
            if tryDisplayMode(.fullTime, timeString: timeString) {
                currentDisplayMode = .fullTime
            } else if tryDisplayMode(.shortTime, timeString: timeString) {
                currentDisplayMode = .shortTime
            } else {
                // Fall back to icon only
                currentDisplayMode = .iconOnly
                statusItem.button?.title = ""
                statusItem.button?.image = NSImage(systemSymbolName: "timer", accessibilityDescription: "Timer: \(timeString)")
                statusItem.button?.toolTip = "Pomodoro Timer: \(timeString)"
            }
        } else {
            // Use full display mode (original behavior)
            statusItem.button?.image = NSImage(systemSymbolName: "clock", accessibilityDescription: nil)
            statusItem.button?.title = timeString
            statusItem.button?.toolTip = "Pomodoro Timer: \(timeString)"
            currentDisplayMode = .fullTime
        }
    }
    
    private func tryDisplayMode(_ mode: StatusBarDisplayMode, timeString: String) -> Bool {
        guard let button = statusItem.button else { return false }
        
        // Save current state
        let originalTitle = button.title
        let originalImage = button.image
        
        // Apply the display mode
        switch mode {
        case .fullTime:
            button.image = NSImage(systemSymbolName: "clock", accessibilityDescription: nil)
            button.title = timeString
        case .shortTime:
            button.image = nil
            button.title = timeString
        case .iconOnly:
            button.image = NSImage(systemSymbolName: "timer", accessibilityDescription: nil)
            button.title = ""
        }
        
        // Check if the status item fits
        button.sizeToFit()
        let buttonWidth = button.frame.width
        let availableWidth = getAvailableStatusBarWidth()
        
        let fits = buttonWidth <= availableWidth
        
        // If it doesn't fit, restore original state
        if !fits {
            button.title = originalTitle
            button.image = originalImage
        }
        
        return fits
    }
    
    private func getAvailableStatusBarWidth() -> CGFloat {
        // Get the status bar and calculate available space
        let statusBar = NSStatusBar.system
        
        // Estimate available width (conservative approach)
        // Account for other status bar items and system controls
        let screenWidth = NSScreen.main?.frame.width ?? 1920
        let estimatedOtherItemsWidth: CGFloat = 400 // Conservative estimate for other menu bar items
        let maxAllowedWidth: CGFloat = 120 // Maximum width we want for our item
        
        let availableWidth = min(maxAllowedWidth, screenWidth - estimatedOtherItemsWidth)
        return max(availableWidth, 60) // Minimum width to ensure icon-only mode works
    }
}

