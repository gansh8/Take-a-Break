//
//  AppPreferences.swift
//  menubarApp
//
//  Created by Ganeshlingam C on 07/04/23.
//

import CoreGraphics
import Foundation

class AppPreferences {
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
    }
}
