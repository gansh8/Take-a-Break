//
//  PreferencesView.swift
//  menubarApp
//
//  Created by Claude on 27/06/25.
//

import SwiftUI
import Foundation

struct PreferencesView: View {
    @State private var selectedTab = PreferenceTab.schedule
    
    var body: some View {
        NavigationSplitView {
            // Sidebar
            List(PreferenceTab.allCases, id: \.self, selection: $selectedTab) { tab in
                Label(tab.displayName, systemImage: tab.iconName)
                    .tag(tab)
            }
            .navigationTitle("Preferences")
            .frame(minWidth: 180)
        } detail: {
            // Detail view
            Group {
                switch selectedTab {
                case .general:
                    GeneralPreferencesView()
                case .schedule:
                    SchedulePreferencesView()
                case .appearance:
                    AppearancePreferencesView()
                case .about:
                    AboutPreferencesView()
                }
            }
            .frame(minWidth: 450, minHeight: 350)
        }
        .frame(width: 650, height: 450)
    }
}

enum PreferenceTab: String, CaseIterable {
    case general = "General"
    case schedule = "Schedule" 
    case appearance = "Appearance"
    case about = "About"
    
    var displayName: String {
        return self.rawValue
    }
    
    var iconName: String {
        switch self {
        case .general: return "gear"
        case .schedule: return "clock"
        case .appearance: return "paintbrush"
        case .about: return "info.circle"
        }
    }
}

struct GeneralPreferencesView: View {
    @State private var launchAtStartup = AppPreferences.shared.launchAtStartup
    @State private var showTimeInMenuBar = AppPreferences.shared.showTimeInMenuBar
    @State private var adaptiveStatusBar = AppPreferences.shared.adaptiveStatusBar
    @State private var playSoundAtEnd = AppPreferences.shared.playSoundAtEnd
    @State private var fadeInBreak = AppPreferences.shared.fadeInBreak
    @State private var pauseAtMouseIdle = AppPreferences.shared.pauseAtMouseIdle
    @State private var enableStandup = AppPreferences.shared.enableStandupBreak
    
    var body: some View {
        Form {
            Section {
                Toggle("Launch at system startup", isOn: $launchAtStartup)
                    .onChange(of: launchAtStartup) { newValue in
                        AppPreferences.shared.launchAtStartup = newValue
                        setLaunchAtStartup(enabled: newValue)
                    }
                
                Toggle("Show time in Menu bar", isOn: $showTimeInMenuBar)
                    .onChange(of: showTimeInMenuBar) { newValue in
                        AppPreferences.shared.showTimeInMenuBar = newValue
                    }
                
                Toggle("Adaptive status bar display", isOn: $adaptiveStatusBar)
                    .onChange(of: adaptiveStatusBar) { newValue in
                        AppPreferences.shared.adaptiveStatusBar = newValue
                    }
            } header: {
                Text("Application")
            } footer: {
                Text("Adaptive display automatically adjusts the status bar item when space is limited - showing icon only or shorter time format.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Section {
                Toggle("Play sound when break ends", isOn: $playSoundAtEnd)
                    .onChange(of: playSoundAtEnd) { newValue in
                        AppPreferences.shared.playSoundAtEnd = newValue
                    }
                
                Toggle("Fade in mask window", isOn: $fadeInBreak)
                    .onChange(of: fadeInBreak) { newValue in
                        AppPreferences.shared.fadeInBreak = newValue
                    }
                
                Toggle("Enable standup break", isOn: $enableStandup)
                    .onChange(of: enableStandup) { newValue in
                        AppPreferences.shared.enableStandupBreak = newValue
                    }
            } header: {
                Text("Break Behavior")
            }
            
            Section {
                Toggle("Pause when mouse inactive", isOn: $pauseAtMouseIdle)
                    .onChange(of: pauseAtMouseIdle) { newValue in
                        AppPreferences.shared.pauseAtMouseIdle = newValue
                        setMouseIdleMonitoring(enabled: newValue)
                    }
            } header: {
                Text("Timer Controls")
            } footer: {
                Text("Timer will pause after 30 seconds of mouse inactivity and resume when mouse moves again.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .formStyle(.grouped)
        .navigationTitle("General")
    }
    
    private func setLaunchAtStartup(enabled: Bool) {
        // This will be implemented via notification to AppDelegate
        NotificationCenter.default.post(name: .setLaunchAtStartup, object: nil, userInfo: ["enabled": enabled])
    }
    
    private func setMouseIdleMonitoring(enabled: Bool) {
        // This will be implemented via notification to AppDelegate
        NotificationCenter.default.post(name: .setMouseIdleMonitoring, object: nil, userInfo: ["enabled": enabled])
    }
}

struct SchedulePreferencesView: View {
    @State private var workTimeMins = AppPreferences.shared.workTimeMins
    @State private var breakTimeSeconds = AppPreferences.shared.breakTimeSeconds
    
    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Work session duration:")
                            .frame(minWidth: 160, alignment: .leading)
                        
                        TextField("Minutes", value: $workTimeMins, format: .number)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 80)
                            .onChange(of: workTimeMins) { newValue in
                                AppPreferences.shared.workTimeMins = newValue
                            }
                        
                        Text("minutes")
                            .foregroundColor(.secondary)
                        
                        Spacer()
                    }
                    
                    HStack {
                        Text("Break reminder duration:")
                            .frame(minWidth: 160, alignment: .leading)
                        
                        TextField("Seconds", value: $breakTimeSeconds, format: .number)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 80)
                            .onChange(of: breakTimeSeconds) { newValue in
                                AppPreferences.shared.breakTimeSeconds = newValue
                            }
                        
                        Text("seconds")
                            .foregroundColor(.secondary)
                        
                        Spacer()
                    }
                }
                .padding(.vertical, 4)
            } header: {
                Text("Timer Settings")
            } footer: {
                Text("Work sessions will run for the specified duration. Break reminders will automatically dismiss after the break duration.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Schedule")
    }
}

struct AppearancePreferencesView: View {
    @State private var backgroundColor = Color(NSColor(cgColor: AppPreferences.shared.breakViewBackgroundColor) ?? NSColor.black)
    @State private var breakMessage = AppPreferences.shared.breakMessage
    
    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Background color:")
                            .frame(minWidth: 120, alignment: .leading)
                        
                        ColorPicker("Background", selection: $backgroundColor, supportsOpacity: false)
                            .labelsHidden()
                            .frame(width: 50)
                            .onChange(of: backgroundColor) { newColor in
                                let nsColor = NSColor(newColor)
                                AppPreferences.shared.breakViewBackgroundColor = nsColor.cgColor
                            }
                        
                        Spacer()
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Break message:")
                        
                        TextField("Enter your break message", text: $breakMessage)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onChange(of: breakMessage) { newValue in
                                AppPreferences.shared.breakMessage = newValue
                            }
                    }
                    
                    HStack {
                        Spacer()
                        Button("Preview Break Screen") {
                            BreakWindowController.shared.showBreakWindow()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding(.vertical, 4)
            } header: {
                Text("Break Screen Customization")
            } footer: {
                Text("Customize how the fullscreen break reminder appears. The preview will show your current settings.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Appearance")
    }
}

struct AboutPreferencesView: View {
    var body: some View {
        Form {
            Section {
                VStack(spacing: 24) {
                    Image(systemName: "timer")
                        .font(.system(size: 60))
                        .foregroundColor(.accentColor)
                    
                    VStack(spacing: 8) {
                        Text("Take a Break")
                            .font(.title2)
                            .fontWeight(.medium)
                        
                        Text("Version 1.0")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Text("A simple and elegant Pomodoro timer that helps you maintain focus and take regular breaks. Built with SwiftUI for macOS.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                    
                    Text("Made in India with ❤️")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            }
            
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Features:")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Customizable work and break durations")
                        }
                        
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Menubar integration with time display")
                        }
                        
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Fullscreen break reminders")
                        }
                        
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Sound notifications")
                        }
                        
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Mouse idle detection")
                        }
                        
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Launch at startup option")
                        }
                    }
                    .font(.caption)
                }
                .padding(.vertical, 4)
            } header: {
                Text("Application Info")
            }
        }
        .formStyle(.grouped)
        .navigationTitle("About")
    }
}

// Window controller for preferences
class PreferencesWindowController: NSObject, ObservableObject {
    static let shared = PreferencesWindowController()
    private var window: NSWindow?
    
    func showPreferences() {
        if window == nil {
            let preferencesView = PreferencesView()
            let hostingController = NSHostingController(rootView: preferencesView)
            
            window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 650, height: 450),
                styleMask: [.titled, .closable, .fullSizeContentView],
                backing: .buffered,
                defer: false
            )
            
            window?.title = "Preferences"
            window?.contentViewController = hostingController
            window?.center()
            window?.setFrameAutosaveName("PreferencesWindow")
        }
        
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}