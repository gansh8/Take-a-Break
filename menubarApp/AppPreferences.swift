//
//  AppPreferences.swift
//  menubarApp
//
//  Created by Ganeshlingam C on 07/04/23.
//

import CoreGraphics
import Foundation
import SwiftUI

class AppPreferences: ObservableObject {
    static var shared = AppPreferences()

    private var _showTimeInMenuBar: Bool = true
    var showTimeInMenuBar: Bool {
        set {
            self._showTimeInMenuBar = newValue
            UserDefaults.standard.set(newValue, forKey: "ShowTimeInMenuBar")
        }
        get {
            return self._showTimeInMenuBar
        }
    }

    private var _breakViewBackgroundColor = CGColor.black
    var breakViewBackgroundColor: CGColor {
        set {
            self._breakViewBackgroundColor = newValue
            UserDefaults.standard.set(newValue.components ?? [], forKey: "BreakViewBackgroundColor")
        }
        get {
            return self._breakViewBackgroundColor
        }
    }
    private var _workTimeMins = 20
    var workTimeMins: Int {
        set {
            self._workTimeMins = newValue
            UserDefaults.standard.set(newValue, forKey: "WorkTimeMins")
        }
        get {
            return self._workTimeMins
        }
    }
    private var _breakTimeSeconds = 20
    var breakTimeSeconds: Int {
        set {
            self._breakTimeSeconds = newValue
            UserDefaults.standard.set(newValue, forKey: "BreakTimeSeconds")
        }
        get {
            return self._breakTimeSeconds
        }
    }
    private var _breakMessage = "Take a Break.!"
    var breakMessage: String {
        set {
            self._breakMessage = newValue
            UserDefaults.standard.set(newValue, forKey: "BreakMessage")
        }
        get {
            return self._breakMessage
        }
    }
    
    private var _launchAtStartup = false
    var launchAtStartup: Bool {
        set {
            self._launchAtStartup = newValue
            UserDefaults.standard.set(newValue, forKey: "LaunchAtStartup")
        }
        get {
            return self._launchAtStartup
        }
    }
    
    private var _playSoundAtEnd = false
    var playSoundAtEnd: Bool {
        set {
            self._playSoundAtEnd = newValue
            UserDefaults.standard.set(newValue, forKey: "PlaySoundAtEnd")
        }
        get {
            return self._playSoundAtEnd
        }
    }
    
    private var _fadeInBreak = false
    var fadeInBreak: Bool {
        set {
            self._fadeInBreak = newValue
            UserDefaults.standard.set(newValue, forKey: "FadeInBreak")
        }
        get {
            return self._fadeInBreak
        }
    }
    
    private var _pauseAtMouseIdle = false
    var pauseAtMouseIdle: Bool {
        set {
            self._pauseAtMouseIdle = newValue
            UserDefaults.standard.set(newValue, forKey: "PauseAtMouseIdle")
        }
        get {
            return self._pauseAtMouseIdle
        }
    }
    
    private var _enableStandupBreak = false
    var enableStandupBreak: Bool {
        set {
            self._enableStandupBreak = newValue
            UserDefaults.standard.set(newValue, forKey: "EnableStandupBreak")
        }
        get {
            return self._enableStandupBreak
        }
    }
    
    private var _adaptiveStatusBar = true
    var adaptiveStatusBar: Bool {
        set {
            self._adaptiveStatusBar = newValue
            UserDefaults.standard.set(newValue, forKey: "AdaptiveStatusBar")
        }
        get {
            return self._adaptiveStatusBar
        }
    }

    private init() {
        self.getAllValuesFromUserDefaults()
    }

    private func getAllValuesFromUserDefaults() {
        if let value = UserDefaults.standard.object(forKey: "ShowTimeInMenuBar") as? Bool {
            self._showTimeInMenuBar = value
        }
        if let rgba = UserDefaults.standard.object(forKey: "BreakViewBackgroundColor") as? [CGFloat] {
            self._breakViewBackgroundColor = CGColor(red: rgba[0], green: rgba[1], blue: rgba[2], alpha: rgba[3])
        }
        if let value = UserDefaults.standard.object(forKey: "WorkTimeMins") as? Int {
            self._workTimeMins = value
        }
        if let value = UserDefaults.standard.object(forKey: "BreakTimeSeconds") as? Int {
            self._breakTimeSeconds = value
        }
        if let value = UserDefaults.standard.object(forKey: "BreakMessage") as? String {
            self._breakMessage = value
        }
        if let value = UserDefaults.standard.object(forKey: "LaunchAtStartup") as? Bool {
            self._launchAtStartup = value
        }
        if let value = UserDefaults.standard.object(forKey: "PlaySoundAtEnd") as? Bool {
            self._playSoundAtEnd = value
        }
        if let value = UserDefaults.standard.object(forKey: "FadeInBreak") as? Bool {
            self._fadeInBreak = value
        }
        if let value = UserDefaults.standard.object(forKey: "PauseAtMouseIdle") as? Bool {
            self._pauseAtMouseIdle = value
        }
        if let value = UserDefaults.standard.object(forKey: "EnableStandupBreak") as? Bool {
            self._enableStandupBreak = value
        }
        if let value = UserDefaults.standard.object(forKey: "AdaptiveStatusBar") as? Bool {
            self._adaptiveStatusBar = value
        }
    }
}
