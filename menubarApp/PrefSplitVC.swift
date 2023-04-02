//
//  PrefSplitVC.swift
//  menubarApp
//
//  Created by Ganeshlingam C on 02/04/23.
//

import Cocoa

class PrefSplitVC: NSSplitViewController {

    @IBOutlet weak var prefContent: NSSplitViewItem!
    @IBOutlet weak var sideBar: NSSplitViewItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        (self.sideBar.viewController as? SideBarVC)?.delegate = self
    }

    func selected(_ value: PreferenceName) {
        (self.prefContent.viewController as? PrefContentVC)?.selected(value)
    }
}

enum PreferenceName {
    case account, general, appearance, customise, about
}

extension PreferenceName {
    var name: String {
        switch self {
        case .general:
            return "General"
        case .about:
            return "About"
        case .account:
            return "Account"
        case .customise:
            return "Schedule"
        case .appearance:
            return "Appearance"
        }
    }

    var image: NSImage! {
        switch self {
        case .general:
            return NSImage(systemSymbolName: "gear", accessibilityDescription: self.name)
        case .about:
            return NSImage(systemSymbolName: "info", accessibilityDescription: self.name)
        case .account:
            return NSImage(systemSymbolName: "person", accessibilityDescription: self.name)
        case .customise:
            return NSImage(systemSymbolName: "switch.2", accessibilityDescription: self.name)
        case .appearance:
            return NSImage(systemSymbolName: "circle.lefthalf.filled", accessibilityDescription: self.name)
        }
    }
}
