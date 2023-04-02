//
//  BreakViewController.swift
//  menubarApp
//
//  Created by Ganeshlingam C on 02/04/23.
//

import Cocoa

class BreakViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func closeTheBreak(_ sender: NSButton) {
        self.view.window?.close()
    }
}
