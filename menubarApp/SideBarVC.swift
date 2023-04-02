//
//  SideBarVC.swift
//  menubarApp
//
//  Created by Ganeshlingam C on 01/04/23.
//

import Cocoa

class SideBarVC: NSViewController {
    @IBOutlet weak var sideTableView: NSTableView!
    weak var delegate: PrefSplitVC?

    private let prefItems: [PreferenceName] = [.account, .general, .appearance, .customise, .about]
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = .clear
        self.sideTableView.register(NSNib(nibNamed: NSNib.Name("SideBarCellView"), bundle: nil), forIdentifier: NSUserInterfaceItemIdentifier("SideBarCellView"))
        self.sideTableView.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)

    }
}

extension SideBarVC: NSTableViewDelegate, NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.prefItems.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let cellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("SideBarCellView"), owner: self) as? SideBarCellView else {
                return nil
            }
        cellView.title.stringValue = self.prefItems[row].name
        cellView.iconView.image = self.prefItems[row].image
        return cellView
    }

    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 44.0
    }

    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        self.delegate?.selected(self.prefItems[row])
        return true
    }
}
