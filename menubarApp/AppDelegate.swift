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

class AppDelegate: NSObject, NSApplicationDelegate, NSPopoverDelegate {
    var statusItem: NSStatusItem!
    var pomodoroTimer: PomodoroTimer!
    var popover: NSPopover!
    var audioPlayer: AVAudioPlayer?
    var eventMonitor: Any?

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
        // Use fixed length to prevent status bar item from moving
        statusItem = NSStatusBar.system.statusItem(withLength: 70)
        statusItem.button?.image = NSImage(systemSymbolName: "clock", accessibilityDescription: nil)
        statusItem.button?.title = "25:00"
        statusItem.button?.target = self
        statusItem.button?.action = #selector(statusItemClicked)
        statusItem.button?.imagePosition = .imageLeading

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
        popover.delegate = self

        let timerView = TimerView(pomodoroTimer: pomodoroTimer)
        popover.contentViewController = NSHostingController(rootView: timerView)
    }

    // MARK: - NSPopoverDelegate
    func popoverShouldClose(_ popover: NSPopover) -> Bool {
        return true
    }

    func popoverDidClose(_ notification: Notification) {
        // Popover closed, nothing special needed
    }
    
    private func togglePopover() {
        if popover.isShown {
            closePopover()
        } else {
            showPopover()
        }
    }

    private func showPopover() {
        NSApplication.shared.activate(ignoringOtherApps: true)
        popover.show(relativeTo: statusItem.button!.bounds, of: statusItem.button!, preferredEdge: .minY)

        // Add event monitor to detect clicks outside popover
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            if self?.popover.isShown == true {
                self?.closePopover()
            }
        }
    }

    private func closePopover() {
        popover.performClose(nil)

        // Remove event monitor
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Cleanup notification observers
        NotificationCenter.default.removeObserver(self)

        // Stop mouse idle monitoring
        setMouseIdleMonitoring(enabled: false)

        // Remove event monitor
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
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
            "AdaptiveStatusBar": true,
            "SelectedBreakPresetId": "stretch"
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

        // Show break window automatically
        BreakWindowController.shared.showBreakWindow()

        // Record session completion
        SessionStatistics.shared.recordSessionComplete()

        // Restart timer automatically after break
        pomodoroTimer?.start()

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
                setDisplayMode(.fullTime, timeString: timeString)
            } else if tryDisplayMode(.shortTime, timeString: timeString) {
                setDisplayMode(.shortTime, timeString: timeString)
            } else {
                setDisplayMode(.iconOnly, timeString: timeString)
            }
        } else {
            // Use full display mode (original behavior)
            setDisplayMode(.fullTime, timeString: timeString)
        }
    }

    private func setDisplayMode(_ mode: StatusBarDisplayMode, timeString: String) {
        currentDisplayMode = mode

        switch mode {
        case .fullTime:
            statusItem.length = 70 // Fixed width for icon + time
            statusItem.button?.image = NSImage(systemSymbolName: "clock", accessibilityDescription: nil)
            statusItem.button?.title = timeString
            statusItem.button?.imagePosition = .imageLeading
        case .shortTime:
            statusItem.length = 50 // Fixed width for time only
            statusItem.button?.image = nil
            statusItem.button?.title = timeString
        case .iconOnly:
            statusItem.length = 30 // Fixed width for icon only
            statusItem.button?.title = ""
            statusItem.button?.image = NSImage(systemSymbolName: "timer", accessibilityDescription: "Timer: \(timeString)")
        }

        statusItem.button?.toolTip = "Pomodoro Timer: \(timeString)"
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
        // Try to get actual status bar position
        guard let button = statusItem.button,
              let window = button.window else {
            return 100 // Default fallback
        }

        // Get the button's position in screen coordinates
        let buttonFrame = window.convertToScreen(button.frame)
        let screenWidth = NSScreen.main?.frame.width ?? 1920

        // Calculate available space to the right edge of the screen
        // This gives us a better estimate of actual available space
        let distanceToEdge = screenWidth - buttonFrame.maxX

        // If we're too close to the edge (less than 50pt), we're likely crowded
        if distanceToEdge < 50 {
            return 40 // Very limited space, use icon only
        } else if distanceToEdge < 150 {
            return 80 // Moderate space, might fit short time
        } else {
            return 120 // Plenty of space, use full display
        }
    }
}

