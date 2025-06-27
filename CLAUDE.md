# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a macOS menubar Pomodoro timer application called "Take a Break" built in Swift using AppKit. The app displays a countdown timer in the menubar and shows fullscreen break reminders.

## Architecture

### Core Components

- **AppDelegate.swift**: Main application entry point that manages the menubar status item and coordinates between the timer and UI components
- **PomodoroTimer.swift**: Core timer logic with delegate pattern for time updates and completion notifications
- **TimerViewController.swift**: Popover UI controller with timer controls (play/pause/reset) and circular progress indicator
- **BreakViewController.swift**: Fullscreen break reminder window with auto-close timer
- **AppPreferences.swift**: Singleton for managing user preferences stored in UserDefaults

### Key Patterns

- Delegate pattern used for timer updates (PomodoroTimerDelegate)
- Singleton pattern for shared preferences (AppPreferences.shared)
- Custom NSView subclass for circular progress visualization (CircularProgressBarView)
- Storyboard-based UI with programmatic popover management

### User Preferences

The app manages these configurable settings via UserDefaults:
- ShowTimeInMenuBar: Display countdown in menubar
- BreakViewBackgroundColor: Background color for break screen
- WorkTimeMins: Work session duration (default 20 minutes)
- BreakTimeSeconds: Break duration (default 20 seconds)
- BreakMessage: Custom break reminder text

## Development Commands

This is an Xcode project. Use Xcode to build and run the application.

- Open `menubarApp.xcodeproj` in Xcode
- Build with Cmd+B
- Run with Cmd+R

## File Structure

- `menubarApp.xcodeproj/`: Xcode project files
- `menubarApp/`: Source code directory
  - UI Controllers: TimerViewController, BreakViewController, preference VCs
  - Core Logic: PomodoroTimer, AppPreferences, AppDelegate
  - UI Resources: Storyboard.storyboard, XIB files, Assets.xcassets