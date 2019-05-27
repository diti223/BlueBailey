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
        return presenter.numberOfChildrenOfItem(item)
    }
    
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        return presenter.child(at: index, ofItem: item)
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return presenter.hasChildren(item: item)
    }
    
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        
        var view: NSTableCellView?
        guard let columnId = tableColumn?.identifier,
            let column = Section(columnId: columnId) else {
                return view
        }
        
        
        return view
    }
    
}

enum Section {
    case component, name, action
}

extension Section {
    init?(columnId: String) {
        switch columnId {
        case "ComponentColumn": self = .component
        case "NameColumn": self = .name
        case "ActionColumn": self = .action
        default: return nil
        }
    }

private extension NSUserInterfaceItemIdentifier {
    static var componentIdentifier = NSUserInterfaceItemIdentifier("Component")
}



