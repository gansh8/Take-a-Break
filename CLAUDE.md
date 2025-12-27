# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a macOS menubar Pomodoro timer application called "Take a Break" built in Swift. The app displays a countdown timer in the menubar and shows fullscreen break reminders.

**Note**: This project has two branches:
- `main`: AppKit-based implementation with Storyboards and XIB files
- `swiftui`: Modern SwiftUI implementation (current branch)

## Development Commands

This is an Xcode project:

- Open `menubarApp.xcodeproj` in Xcode
- Build with ⌘+B
- Run with ⌘+R
- Clean build folder with ⌘+Shift+K

## Architecture (SwiftUI Branch)

### Application Flow

1. **AppDelegate** serves as the main entry point and coordinator:
   - Creates the menubar status item (NSStatusItem) with clock icon and time display
   - Instantiates and starts the PomodoroTimer on launch
   - Acts as PomodoroTimerDelegate to receive timer updates
   - Updates the menubar title with remaining time in MM:SS format
   - Implements adaptive status bar display that adjusts to available space
   - Manages mouse idle monitoring for automatic pause/resume
   - Handles launch-at-startup functionality via ServiceManagement framework

2. **PomodoroTimer** (ObservableObject) manages countdown logic:
   - Uses Foundation Timer with 1-second intervals
   - Maintains remainingTime and duration state
   - Notifies delegate via didUpdateRemainingTime and didFinish callbacks
   - Posts NotificationCenter notifications for SwiftUI view updates
   - **Timer Persistence**: Saves/restores state across app restarts
   - Accounts for elapsed time when app was closed (if timer was running)
   - Pause/resume for both manual and idle detection scenarios

3. **TimerView** (SwiftUI) displays the popover UI:
   - Shows countdown with animated circular progress indicator
   - Displays session statistics (today's count, streak, total sessions)
   - Contains play/pause, reset, and next (force break) buttons with tooltips
   - Gradient progress ring with smooth animations
   - Listens to NotificationCenter for timer state changes
   - Syncs pause button state with timer's actual isPaused state

4. **BreakView** (SwiftUI) presents fullscreen break screen:
   - Shown via BreakWindowController.shared singleton
   - Window level set to .screenSaver to appear above all windows
   - Optional fade-in animation for smooth transition
   - Two display modes: standard message or standup break reminder
   - Auto-closes after BreakTimeSeconds with Skip button option
   - Properly cleans up timer on dismissal

5. **PreferencesView** (SwiftUI) uses NavigationSplitView:
   - Sidebar with General, Schedule, Appearance, and About tabs
   - GeneralPreferencesView: Launch at startup, display options, sound, idle detection
   - SchedulePreferencesView: Work duration and break duration settings
   - AppearancePreferencesView: Break screen color, message, and live preview
   - AboutPreferencesView: App information and feature list
   - PreferencesWindowController manages window lifecycle

6. **SessionStatistics** (ObservableObject) tracks user progress:
   - Records completed sessions automatically when timer finishes
   - Tracks today's session count (resets daily)
   - Maintains current streak (consecutive days with sessions)
   - Tracks longest streak and total sessions all-time
   - Handles streak logic (breaks if a day is skipped)
   - Persists data to UserDefaults

### Key Implementation Details

- **Delegate + Notifications**: Hybrid approach using PomodoroTimerDelegate for AppDelegate and NotificationCenter for SwiftUI views
- **Singleton Pattern**: AppPreferences.shared, SessionStatistics.shared, window controllers
- **SwiftUI Animations**: Smooth progress ring transitions, fade-in effects for break window
- **Window Management**: BreakWindowController uses DispatchQueue.main.async for safe window closing
- **State Synchronization**: Pause state synced via notifications to prevent UI/logic mismatch
- **Adaptive UI**: Status bar display mode adjusts based on available menubar space

### User Preferences (UserDefaults Keys)

**Timer Settings:**
- **WorkTimeMins** (Int): Work session duration in minutes (default: 20)
- **BreakTimeSeconds** (Int): Break screen auto-close duration (default: 20)

**Display Settings:**
- **ShowTimeInMenuBar** (Bool): Toggle countdown display in menubar (default: true)
- **AdaptiveStatusBar** (Bool): Auto-adjust menubar display for space (default: true)

**Break Screen:**
- **BreakViewBackgroundColor** (CGColor components): Background color (default: black)
- **BreakMessage** (String): Custom break message (default: "Take a Break.!")
- **FadeInBreak** (Bool): Fade-in animation for break window (default: false)
- **EnableStandupBreak** (Bool): Show standup reminder instead of message (default: false)

**App Behavior:**
- **LaunchAtStartup** (Bool): Launch app at system startup (default: false)
- **PlaySoundAtEnd** (Bool): Play sound when timer completes (default: false)
- **PauseAtMouseIdle** (Bool): Auto-pause when mouse inactive for 30s (default: false)

**Statistics (Internal):**
- TodaySessionCount, TodayDate, TotalSessionCount, CurrentStreak, LongestStreak, LastSessionDate

### UI Structure

- **SwiftUI Views Only**: No Storyboards or XIB files
- **TimerView**: Main popover content with timer, stats, and controls
- **BreakView**: Fullscreen break reminder
- **PreferencesView**: Multi-tab preferences interface with NavigationSplitView
- **Window Controllers**: NSHostingController instances wrap SwiftUI views
- **Programmatic UI**: All menubar, popover, and window management in code