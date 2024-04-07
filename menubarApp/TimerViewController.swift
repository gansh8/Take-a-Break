//
//  TimerViewController.swift
//  menubarApp
//
//  Created by Ganeshlingam C on 01/04/23.
//

import Cocoa

class TimerViewController: NSViewController {

    weak var timerDelegate: PomodoroTimer?

    @IBOutlet weak var timeLabel: NSTextField!
    @IBOutlet weak var progressIndicator: CircularProgressBarView!

    var popover: NSPopover!

    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.setupPopover()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    @IBAction func showMenu(_ sender: NSButton) {
        let menu = NSMenu(title: "Menu")
        let breakItem = NSMenuItem(title: "Break", action: #selector(onMenuItemSelected(_:)), keyEquivalent: "")
        breakItem.tag = 1
        let prefItem = NSMenuItem(title: "Preferences", action: #selector(onMenuItemSelected(_:)), keyEquivalent: "")
        prefItem.tag = 2
        let quitItem = NSMenuItem(title: "Quit", action: #selector(onMenuItemSelected(_:)), keyEquivalent: "")
        quitItem.tag = 3
        menu.addItem(breakItem)
        menu.addItem(prefItem)
        menu.addItem(quitItem)
        NSMenu.popUpContextMenu(menu, with: NSApplication.shared.currentEvent!, for: sender)
    }

    @objc func onMenuItemSelected(_ sender: NSMenuItem) {
        if sender.tag == 1 {
            FullScreenWindowController.showBreakWindow()
        } else if sender.tag == 3 {
            popover.performClose(nil)
            NSApplication.shared.terminate(nil)
        } else if sender.tag == 2 {
            let storyboard = NSStoryboard(name: "Storyboard", bundle: nil)
            guard let windowController = storyboard.instantiateController(withIdentifier: "PreferencesWindowController") as? NSWindowController else {
                fatalError("Unable to load preferences window controller.")
            }
            windowController.showWindow(self)
        }
        print("Menu item selected: \(sender.title)")
    }

    @IBAction func resetTimer(_ sender: NSButton) {
        self.timerDelegate?.stop()
        self.timerDelegate?.start()
    }

    @IBAction func pauseTimer(_ sender: NSButton) {
        self.timerDelegate?.pause()
        sender.image = sender.state == .on ? NSImage(systemSymbolName: "play.circle", accessibilityDescription: nil) : NSImage(systemSymbolName: "pause.circle", accessibilityDescription: nil)
    }

    @IBAction func nextTimer(_ sender: NSButton) {
        FullScreenWindowController.showBreakWindow()
        self.timerDelegate?.stop()
        self.timerDelegate?.start()
    }
    
    func setupPopover() {
        // Create popover
        popover = TimerPopover()
        popover.contentViewController = self
        popover.behavior = .transient
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear() {
        self.view.window?.makeFirstResponder(popover)
    }

    func updateTimeLabel(_ timeString: String) {
        timeLabel?.stringValue = timeString
    }

    func updateProgressIndicator(_ progress: Double) {
        progressIndicator?.setProgress(progress)
    }

    func togglePopover(_ sender: NSButton) {
        if popover.isShown {
            popover.performClose(nil)
        } else {
            NSApplication.shared.activate(ignoringOtherApps: true)
            popover.show(relativeTo: sender.bounds, of: sender, preferredEdge: .minY)
        }
    }

    override func viewWillDisappear() {
        popover.performClose(nil)
    }
}


class CircularProgressBarView: NSView {
    private var progress: Double = 1.0

    override func draw(_ dirtyRect: NSRect) {
        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        let radius = min(bounds.width, bounds.height) / 2 - 5
        let startAngle = 90.0 + 360 * (1 - progress)
        let endAngle = 90.0
        let pathg = NSBezierPath()
        pathg.appendArc(withCenter: center, radius: radius, startAngle: -90.0, endAngle: 270, clockwise: false)
        NSColor.gray.setStroke()
        pathg.stroke()

        let path = NSBezierPath()
        path.appendArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        NSColor.red.setStroke()
        path.stroke()
    }

    func setProgress(_ progress: CGFloat) {
        self.progress = progress
        self.needsDisplay = true
    }
}

class FullScreenWindowController: NSWindowController {
    override func windowDidLoad() {
        super.windowDidLoad()
        window?.level = .screenSaver
        window?.setFrame(NSScreen.main?.frame ?? .zero, display: true)
        window?.toggleFullScreen(nil)
        window?.toolbar?.isVisible = false
        window?.toolbar = nil
        window?.makeFirstResponder(nil)
        window?.alphaValue = 1.0
    }

    static func showBreakWindow() {
        let storyboard = NSStoryboard(name: "Storyboard", bundle: nil)
        guard let windowController = storyboard.instantiateController(withIdentifier: "FullScreenWindowController") as? FullScreenWindowController else {
            fatalError("Unable to load preferences window controller.")
        }
        windowController.showWindow(nil)
    }
}

class TimerPopover: NSPopover {
    override func keyDown(with event: NSEvent) {
        if event.modifierFlags.contains(.command) {
            if event.keyCode == 12 || event.keyCode == 13 {
                NSApplication.shared.terminate(nil)
            } else {
                super.keyDown(with: event)
            }
        }
    }
}
