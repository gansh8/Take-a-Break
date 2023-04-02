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
    @IBOutlet weak var versionLabel: NSTextField!

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
        self.accountView.isHidden = false
    }

    func hideAllViews() {
        self.accountView.isHidden = true
        self.generalView.isHidden = true
        self.aboutView.isHidden = true
        self.appearanceView.isHidden = true
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
            self.generalView.isHidden = true
        case .appearance:
            self.appearanceView.isHidden = false
        }
        self.view.window?.title = value.name
    }

    func setupGeneralView() {
        self.generalView.isHidden = true
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
