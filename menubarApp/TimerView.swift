//
//  TimerView.swift
//  menubarApp
//
//  Created by Claude on 27/06/25.
//

import SwiftUI

struct TimerView: View {
    @ObservedObject var pomodoroTimer: PomodoroTimer
    @ObservedObject private var stats = SessionStatistics.shared
    @State private var timeString = "25:00"
    @State private var progress: Double = 1.0
    @State private var isPaused = false
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 20) {
            // Progress circle with time
            ZStack {
                CircularProgressView(progress: progress)
                    .frame(width: 200, height: 200)

                Text(timeString)
                    .font(.system(size: 22, weight: .medium, design: .monospaced))
                    .foregroundColor(.primary)
            }

            // Statistics display
            HStack(spacing: 20) {
                VStack(spacing: 4) {
                    Text("\(stats.todaySessionCount)")
                        .font(.system(size: 18, weight: .semibold))
                    Text("Today")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }

                VStack(spacing: 4) {
                    Text("\(stats.currentStreak)")
                        .font(.system(size: 18, weight: .semibold))
                    Text("Streak")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }

                VStack(spacing: 4) {
                    Text("\(stats.totalSessionCount)")
                        .font(.system(size: 18, weight: .semibold))
                    Text("Total")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(8)
            
            // Control buttons
            HStack(spacing: 20) {
                Button(action: resetTimer) {
                    Image(systemName: "arrow.clockwise")
                        .font(.title2)
                        .foregroundColor(.primary)
                        .frame(width: 44, height: 44)
                        .background(Color.secondary.opacity(0.1))
                        .clipShape(Circle())
                }
                .buttonStyle(PlainButtonStyle())
                .help("Reset timer (⌘R)")

                Button(action: togglePause) {
                    Image(systemName: isPaused ? "play.circle.fill" : "pause.circle.fill")
                        .font(.system(size: 36))
                        .foregroundColor(.accentColor)
                }
                .buttonStyle(PlainButtonStyle())
                .help("Pause/Resume (Space)")

                Button(action: nextTimer) {
                    Image(systemName: "forward.circle")
                        .font(.title2)
                        .foregroundColor(.primary)
                        .frame(width: 44, height: 44)
                        .background(Color.secondary.opacity(0.1))
                        .clipShape(Circle())
                }
                .buttonStyle(PlainButtonStyle())
                .help("Start break (Return)")
            }
            .padding(.bottom, 10)
        }
        .padding()
        .frame(width: 300, height: 406)
        .background(Color(NSColor.controlBackgroundColor))
        .overlay(
            HStack {
                Spacer()
                VStack {
                    Button(action: showMenu) {
                        Image(systemName: "list.bullet.indent")
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                    .buttonStyle(PlainButtonStyle())
                    Spacer()
                }
                .padding(.top, 8)
                .padding(.trailing, 8)
            }
        )
        .onReceive(NotificationCenter.default.publisher(for: .pomodoroTimerUpdate)) { notification in
            if let userInfo = notification.userInfo,
               let remainingTime = userInfo["remainingTime"] as? TimeInterval,
               let duration = userInfo["duration"] as? TimeInterval {
                updateDisplay(remainingTime: remainingTime, duration: duration)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .pomodoroTimerFinished)) { _ in
            timeString = "25:00"
            progress = 1.0
            isPaused = false
        }
        .onReceive(NotificationCenter.default.publisher(for: .pomodoroTimerPausedChanged)) { notification in
            if let userInfo = notification.userInfo,
               let paused = userInfo["isPaused"] as? Bool {
                isPaused = paused
            }
        }
        .onAppear {
            // Sync initial pause state
            isPaused = pomodoroTimer.isTimerPaused
            isFocused = true
        }
        .focusable()
        .focused($isFocused)
    }

    private func updateDisplay(remainingTime: TimeInterval, duration: TimeInterval) {
        let minutes = Int(remainingTime) / 60
        let seconds = Int(remainingTime) % 60
        timeString = String(format: "%02d:%02d", minutes, seconds)

        withAnimation(.easeInOut(duration: 0.3)) {
            progress = remainingTime / duration
        }
    }

    private func resetTimer() {
        pomodoroTimer.stop()
        pomodoroTimer.start()
        isPaused = false
    }

    private func togglePause() {
        pomodoroTimer.pause()
        isPaused = pomodoroTimer.isTimerPaused
    }
    
    private func nextTimer() {
        BreakWindowController.shared.showBreakWindow()
        pomodoroTimer.stop()
        pomodoroTimer.start()
        isPaused = false
    }
    
    private func showMenu() {
        let menu = NSMenu()
        let menuHandler = TimerViewMenuHandler.shared
        
        let breakItem = NSMenuItem(title: "Break", action: #selector(TimerViewMenuHandler.showBreak), keyEquivalent: "")
        breakItem.target = menuHandler
        
        let prefItem = NSMenuItem(title: "Preferences", action: #selector(TimerViewMenuHandler.showPreferences), keyEquivalent: "")
        prefItem.target = menuHandler
        
        let quitItem = NSMenuItem(title: "Quit", action: #selector(TimerViewMenuHandler.quit), keyEquivalent: "")
        quitItem.target = menuHandler
        
        menu.addItem(breakItem)
        menu.addItem(prefItem)
        menu.addItem(quitItem)
        
        if let button = NSApp.windows.first?.contentView?.subviews.first(where: { $0 is NSButton }) as? NSButton {
            menu.popUp(positioning: nil, at: button.bounds.origin, in: button)
        } else if let event = NSApplication.shared.currentEvent {
            NSMenu.popUpContextMenu(menu, with: event, for: NSView())
        }
    }
}

struct CircularProgressView: View {
    let progress: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 10)

            Circle()
                .trim(from: 0, to: CGFloat(progress))
                .stroke(
                    LinearGradient(
                        colors: [Color.green, Color.orange, Color.red],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.3), value: progress)

            // Add subtle shadow
            Circle()
                .trim(from: 0, to: CGFloat(progress))
                .stroke(Color.black.opacity(0.1), lineWidth: 11)
                .rotationEffect(.degrees(-90))
                .blur(radius: 2)
                .offset(y: 1)
        }
    }
}

// Helper class for menu actions
class TimerViewMenuHandler: NSObject {
    static let shared = TimerViewMenuHandler()
    
    @objc func showBreak() {
        BreakWindowController.shared.showBreakWindow()
    }
    
    @objc func showPreferences() {
        PreferencesWindowController.shared.showPreferences()
    }
    
    @objc func quit() {
        NSApplication.shared.terminate(nil)
    }
}

// Notification extensions
extension Notification.Name {
    static let pomodoroTimerUpdate = Notification.Name("pomodoroTimerUpdate")
    static let pomodoroTimerFinished = Notification.Name("pomodoroTimerFinished")
    static let pomodoroTimerPausedChanged = Notification.Name("pomodoroTimerPausedChanged")
    static let setLaunchAtStartup = Notification.Name("setLaunchAtStartup")
    static let setMouseIdleMonitoring = Notification.Name("setMouseIdleMonitoring")
}