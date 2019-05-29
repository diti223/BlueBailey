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
        return presenter.isGroup(item: item)
    }
    
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        
        guard let columnId = tableColumn?.identifier,
            let section = Section(columnId: columnId),
            presenter.shouldDisplayView(for: item, in: section) else {
                return nil
        }
        
        
        guard let view = outlineView.makeView(withIdentifier: section.cellId, owner: nil) as? NSTableCellView else {
            return nil
        }
        presenter.configure(itemView: view, with: item, in: section)
        
        return view
    }
    
}

enum Section {
    case component, name, action
}

extension Section {
    init?(columnId: NSUserInterfaceItemIdentifier) {
        switch columnId.rawValue {
        case "ComponentColumn": self = .component
        case "NameColumn": self = .name
        case "ActionColumn": self = .action
        default: return nil
        }
    }
    
    var cellId: NSUserInterfaceItemIdentifier {
        let rawValue = String(describing: self).capitalized + "Cell"
        return .init(rawValue)
    }
}



extension NSTableCellView: DomainComponentView {
    func display(name: String) {
        textField?.stringValue = name
        textField?.sizeToFit()
    }
}
