//
//  SideBarCellView.swift
//  menubarApp
//
//  Created by Ganeshlingam C on 01/04/23.
//

import Cocoa

class SideBarCellView: NSView {
    @IBOutlet weak var iconView: NSImageView!
    @IBOutlet weak var title: NSTextField!

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
}
