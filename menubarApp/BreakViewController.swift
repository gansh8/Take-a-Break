//
//  BreakViewController.swift
//  menubarApp
//
//  Created by Ganeshlingam C on 02/04/23.
//

import Cocoa

class BreakViewController: NSViewController {

    private var autoClose = true
    private var timer: Timer?
    private var remainingTime: TimeInterval!

    @IBOutlet weak var mainContent: NSTextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = AppPreferences.shared.breakViewBackgroundColor
        if self.autoClose {
            self.remainingTime = TimeInterval(AppPreferences.shared.breakTimeSeconds)
            // start timer
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                // Update remaining time and call delegate method
                self?.remainingTime -= 1
                if self?.remainingTime ?? 0 <= 0 {
                    self?.timer?.invalidate()
                    self?.timer = nil
                    self?.view.window?.close()
                }
            }
        }
        self.mainContent.stringValue = AppPreferences.shared.breakMessage
    }
    
    @IBAction func closeTheBreak(_ sender: NSButton) {
        self.timer?.invalidate()
        self.timer = nil
        self.view.window?.close()
    }
}
