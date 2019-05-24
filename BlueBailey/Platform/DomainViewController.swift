//
//  DomainViewController.swift
//  BlueBailey
//
//  Created by Adrian-Dieter Bilescu on 5/23/19
//  Copyright © 2019 Bilescu. All rights reserved.
//

import AppKit

class DomainViewController: NSViewController {
    var presenter: DomainPresenter!

}

extension DomainViewController: DomainView {
    
}


extension DomainViewController: NSOutlineViewDelegate, NSOutlineViewDataSource {
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        return 
    }
//    func numberOfRows(in tableView: NSTableView) -> Int {
//        return presenter.numberOfComponents
//    }
//
//    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
//        guard let identifier = tableColumn?.identifier else { return nil }
//        if tableColumn?.identifier == .componentIdentifier {
//            let cell = tableView.makeView(withIdentifier: identifier, owner: nil) as? NSTableCellView
//
////            cell?.title = presenter.componentTitle(at: row)
//        }
//        return nil
//    }
}

private extension NSUserInterfaceItemIdentifier {
    static var componentIdentifier = NSUserInterfaceItemIdentifier("Component")
}
