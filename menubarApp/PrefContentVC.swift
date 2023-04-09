//
//  PrefContentVC.swift
//  menubarApp
//
//  Created by Ganeshlingam C on 02/04/23.
//

import Cocoa

class PrefContentVC: NSViewController {

    @IBOutlet weak var accountView: NSView!
    @IBOutlet weak var generalView: NSView!
    @IBOutlet weak var appearanceView: NSView!
    @IBOutlet weak var aboutView: NSView!
    @IBOutlet weak var scheduleView: NSView!
    @IBOutlet weak var versionLabel: NSTextField!

    // Switches in General Section
    @IBOutlet weak var launchAtStartup: NSSwitch!
    @IBOutlet weak var showTimeInMenu: NSSwitch!
    @IBOutlet weak var playSoundAtEnd: NSSwitch!
    @IBOutlet weak var fadeInBreak: NSSwitch!
    @IBOutlet weak var pauseAtMouseIdle: NSSwitch!
    @IBOutlet weak var enableStandup: NSSwitch!

    // Appearance
    @IBOutlet weak var colorWell: NSColorWell! // Break Appearance.
    @IBOutlet weak var breakMessageTF: NSTextField!

    // Schedule
    @IBOutlet weak var workTimeMins: NSTextField!
    @IBOutlet weak var breakTimeSeconds: NSTextField!

    private var appearanceList: [Appearance] = [
        Appearance(name: "Break 1", elements: [], skipButton: NSButton.skipButton(#selector(PrefContentVC.skipButtonClicked))),
        Appearance(name: "Break 2", elements: [], skipButton: NSButton.skipButton(#selector(PrefContentVC.skipButtonClicked)))
    ]

    @objc
    static func skipButtonClicked() {
        print("Skipp..!")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupGeneralView()
        self.setupAboutView()
        self.setupAppearanceView()
        self.setupScheduleView()
        self.hideAllViews()
        self.accountView.isHidden = false
    }

    func hideAllViews() {
        self.accountView.isHidden = true
        self.generalView.isHidden = true
        self.aboutView.isHidden = true
        self.appearanceView.isHidden = true
        self.scheduleView.isHidden = true
    }

    func selected(_ value: PreferenceName) {
        self.hideAllViews()
        switch value {
        case .general:
            self.generalView.isHidden = false
        case .about:
            self.aboutView.isHidden = false
        case .account:
            self.accountView.isHidden = false
        case .customise:
            self.scheduleView.isHidden = false
        case .appearance:
            self.appearanceView.isHidden = false
        }
        self.view.window?.title = value.name
    }

    func setupGeneralView() {
        // Disable switches that not implemented.
        self.launchAtStartup.isEnabled = false
        self.playSoundAtEnd.isEnabled = false
        self.fadeInBreak.isEnabled = false
        self.pauseAtMouseIdle.isEnabled = false
        self.enableStandup.isEnabled = false
        self.showTimeInMenu.isEnabled = true
        // Delegates
        self.launchAtStartup.target = self
        self.playSoundAtEnd.target = self
        self.fadeInBreak.target = self
        self.pauseAtMouseIdle.target = self
        self.enableStandup.target = self
        self.showTimeInMenu.target = self

        self.launchAtStartup.action = #selector(self.toggledSwitch(_:))
        self.playSoundAtEnd.action = #selector(self.toggledSwitch(_:))
        self.fadeInBreak.action = #selector(self.toggledSwitch(_:))
        self.pauseAtMouseIdle.action = #selector(self.toggledSwitch(_:))
        self.enableStandup.action = #selector(self.toggledSwitch(_:))
        self.showTimeInMenu.action = #selector(self.toggledSwitch(_:))
        // Initial values for switches
        self.showTimeInMenu.state = AppPreferences.shared.showTimeInMenuBar ? .on : .off
    }

    @objc
    func toggledSwitch(_ sender: NSSwitch) {
        if sender == self.showTimeInMenu {
            AppPreferences.shared.showTimeInMenuBar = self.showTimeInMenu.state == .on
        } else {
            assertionFailure("Not Implemented..!")
        }
    }

    func setupAppearanceView() {
        self.colorWell.target = self
        self.colorWell.action = #selector(self.selectedColor(_:))
        self.colorWell.color = NSColor(cgColor: AppPreferences.shared.breakViewBackgroundColor) ?? .black
        self.breakMessageTF.stringValue = AppPreferences.shared.breakMessage
    }

    @IBAction func updateBreakMessage(_ sender: NSTextField) {
        AppPreferences.shared.breakMessage = sender.stringValue
    }

    @objc
    func selectedColor(_ sender: NSColorWell) {
        AppPreferences.shared.breakViewBackgroundColor = self.colorWell.color.cgColor
    }

    @IBAction func showPreview(_ sender: NSButton) {
        FullScreenWindowController.showBreakWindow()
    }

    @IBAction func updateWorkTime(_ sender: NSTextField) {
        AppPreferences.shared.workTimeMins = sender.integerValue
    }

    @IBAction func updateBreakTime(_ sender: NSTextField) {
        AppPreferences.shared.breakTimeSeconds = sender.integerValue
    }

    func setupScheduleView() {
        self.workTimeMins.integerValue = AppPreferences.shared.workTimeMins
        self.breakTimeSeconds.integerValue = AppPreferences.shared.breakTimeSeconds
    }

    func setupAboutView() {
        self.aboutView.isHidden = true
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            versionLabel.stringValue = "Version \(version)"
        } else {
            versionLabel.stringValue = "Version Unknown"
        }
    }
}

enum Appearance_Element_Type {
    case text, image, clock, button
}

struct Appearance_Element {
    var type: Appearance_Element_Type
    var frame: CGRect
    var maskToBounds: Bool // For crop to frame
    var textElement: AttributedString
    var imageElement: NSImage
    // buttonElement is for skipButton customisation.
    var buttonElement: NSButton // in data title, frame, border, fill, corner radius
}

struct Appearance {
    var name: String
    var elements: [Appearance_Element]
    var skipButton: NSButton
}

extension Appearance {
    func thumbColor() -> CGColor {
        return .random
    }
}

extension CGColor {
    public static var random: CGColor {
        let hue = CGFloat.random(in: 0.0...1.0) //  0.0 to 1.0
        let saturation = CGFloat.random(in: 0.5...1.0) //  0.5 to 1.0, away from white
        let brightness = CGFloat.random(in: 0.5...1.0) //  0.5 to 1.0, away from black
        return CGColor(red: hue, green: saturation, blue: brightness, alpha: 1.0)
    }
}

extension NSButton {
    public static func skipButton(_ selector: Selector?) -> NSButton {
        let button = NSButton()
        button.title = "Skip"
        button.action = selector
        return button
    }
}
