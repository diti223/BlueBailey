//
//  DomainViewController.swift
//  BlueBailey
//
//  Created by Adrian-Dieter Bilescu on 5/23/19
//  Copyright © 2019 Bilescu. All rights reserved.
//

import AppKit

class DomainViewController: NSViewController, DomainComponentNameCellDelegate {
    var presenter: DomainPresenter!
    @IBOutlet weak var outlineView: NSOutlineView!

    override func viewDidLoad() {
        super.viewDidLoad()
        outlineView.autoresizesOutlineColumn = true
        presenter.viewDidLoad()
    }
    
    @IBAction func addAction(_ sender: Any) {
        guard let item = itemOf(sender) else { return }
        presenter.addComponent(for: item)
    }
    
    @IBAction func removeAction(_ sender: Any) {
        guard let item = itemOf(sender) else { return }
        presenter.removeComponent(item)
    }
    
    @IBAction func createFilesAction(_ sender: Any) {
        presenter.createFiles()
    }
    
    private func itemOf(_ sender: Any) -> Any? {
        guard let senderView = sender as? NSView else {
            return nil
        }
        return outlineView.item(for: senderView)
    }
    
    func textEditingEnded(in control: NSControl, text: String) {
        guard let item = itemOf(control) else { return }
        let text: String? = text.isEmpty ? nil : text
        presenter.editName(text, of: item)
    }
    
}

extension DomainViewController: DomainView {
    func reloadData() {
        outlineView.reloadData()
    }
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
            presenter.shouldDisplayView(for: item, in: section) == true else {
                return nil
        }

        guard let view = outlineView.makeView(withIdentifier: section.cellId, owner: nil) as? NSTableCellView else {
            return nil
        }
        
        (view as? DomainComponentNameCell)?.delegate = self
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

extension NSTableCellView: DomainComponentItemView {
    func displayName(_ name: String) {
        textField?.stringValue = name
        textField?.sizeToFit()
    }
}

extension NSTableCellView: DomainComponentNameView {
    func displaySuggested(_ name: String) {
        textField?.isEditable = true
        textField?.isSelectable = true
        textField?.stringValue = name
        textField?.sizeToFit()
    }
}

extension NSTableCellView: DomainComponentActionView {
    func displayAddAction(_ shouldDisplay: Bool) {
        viewWithTag(0)?.isHidden = !shouldDisplay
    }
    
    func displayRemoveAction(_ shouldDisplay: Bool) {
        viewWithTag(1)?.isHidden = !shouldDisplay
    }
}

extension NSOutlineView {
    func item(for view: NSView) -> Any? {
        return item(atRow: row(for: view))
    }
}


protocol DomainComponentNameCellDelegate: class {
    func textEditingEnded(in control: NSControl, text: String)
}

class DomainComponentNameCell: NSTableCellView, NSTextFieldDelegate {
//    @IBOutlet weak var textView: NSTextView!
    weak var delegate: DomainComponentNameCellDelegate?
    
    func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        delegate?.textEditingEnded(in: control, text: fieldEditor.string)
        return true
    }
}
