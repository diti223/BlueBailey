//
//  NavigatorViewController.swift
//  BlueBailey
//
//  Created by Adrian-Dieter Bilescu on 5/14/19.
//  Copyright © 2019 Bilescu. All rights reserved.
//

import Cocoa

class NavigatorViewController: NSViewController {
    @IBOutlet weak var browser: NSBrowser!
    @IBOutlet var cellMenu: NSMenu!
    @IBOutlet weak var moduleNameTextField: NSTextField!
    @IBOutlet weak var platformMenu: NSPopUpButton!
    @IBOutlet weak var targetsTable: NSTableView!
    
    var presenter: NavigatorPresenter!
    let manager = FileManager.default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        browser.columnResizingType = .autoColumnResizing
        presenter.viewDidLoad()
        browser.allowsMultipleSelection = true
        browser.menu = cellMenu
        createPlatformMenu()
    }
    
    // MARK: - Actions
    
    @IBAction func addNewFile(sender: Any) {
        selectNode()
        presenter.addNewFile()
    }
    
    @IBAction func addNewFolder(sender: Any) {
        selectNode()
        presenter.addNewFolder()
    }
    
    @IBAction func deleteFile(sender: Any) {
        let selectedColumn = browser.selectedColumn
        browser.selectedRowIndexes(inColumn: selectedColumn)?.compactMap({
            browser.item(atRow: $0, inColumn: selectedColumn) as? Node
        }).forEach({
            presenter.selectNode($0)
            presenter.deleteFile()
        })
    }
    
    @IBAction func renameFile(sender: Any) {
        selectNode()
        let column = browser.selectedColumn
        let row = browser.selectedRow(inColumn: column)
        let indexPath = IndexPath(item: row, section: column)
        browser.editItem(at: indexPath, with: nil, select: true)
    }
    
    @IBAction func createMVPFiles(sender: Any) {
        guard !moduleNameTextField.stringValue.isEmpty else { return }
        selectNode()
        presenter.createMVPFiles(moduleName: moduleNameTextField.stringValue)
    }
    
    @IBAction func refreshAction(sender: Any) {
        presenter.refreshProject()
    }
    
    @IBAction func openDocument(_ sender: Any?) {
        ViewController.openNewProjectPanel()
    }
    
    @IBAction func targetSelectionChanged(sender: Any) {
        guard let cellView = (sender as? NSButton)?.superview else { return }
        let index = targetsTable.row(for: cellView)
        presenter.selectTarget(at: index)
    }
    
    @IBAction func platformSelectionChanged(sender: Any) {
        presenter.selectPlatform(at: platformMenu.indexOfSelectedItem)
    }
    
    @IBAction func openUseCaseViewController(_ sender: Any) {
        selectNode()
        presenter.openDomainController()
    }
    
    @IBAction func sortCompileSources(_ sender: Any) {
        presenter.sortCompileSources()
    }
    
    // MARK: - Private Methods
    
    private var selectedNode: Node? {
        let column = browser.selectedColumn
        guard column >= 0 else { return nil }
        let row = browser.selectedRow(inColumn: column)
        guard row >= 0 else { return nil }
        return browser.item(atRow: row, inColumn: column) as? Node
    }
    
    private func selectNode() {
        guard let node = selectedNode else {
            presenter.selectNode(presenter.rootNode)
            return
        }
        presenter.selectNode(node)
    }
    
    private func createPlatformMenu() {
        platformMenu.removeAllItems()
        (0..<presenter.numberOfPlatforms).forEach { platformMenu.addItem(withTitle: presenter.platformTitle(at: $0))}
    }
}

extension NavigatorViewController: NavigatorView {
    func displayProject(named: String) {
        view.window?.title = named
    }
    
    func reloadAll() {
        browser.loadColumnZero()
    }
    
    func reloadCurrentSection() {
        var column = browser.selectedColumn
        if column < 0 {
            column = 0
        }
        browser.reloadColumn(column)
    }
    
    func reloadChildSection() {
        browser.reloadColumn(browser.selectedColumn+1)
    }
    
    func reloadParentSection() {
        let previousColumn = browser.selectedColumn-1
        browser.selectRow(browser.selectedRow(inColumn: previousColumn), inColumn: previousColumn)
    }
    
    func select(row: Int) {
        let column = browser.selectedColumn
        browser.selectRow(row, inColumn: column)
    }
}

extension NavigatorViewController: NSBrowserDelegate {
    
    func rootItem(for browser: NSBrowser) -> Any? {
        return presenter.rootNode
    }

    func browser(_ browser: NSBrowser, numberOfChildrenOfItem item: Any?) -> Int {
        guard let node = item as? Node else { return 0 }
        return node.children.count
    }

    func browser(_ browser: NSBrowser, child index: Int, ofItem item: Any?) -> Any {
        guard let node = item as? Node else { return Node(item: .empty) }
        return node.children[index]
    }


    func browser(_ browser: NSBrowser, isLeafItem item: Any?) -> Bool {
        guard let node = item as? Node else { return false }
        return node.children.isEmpty
    }


    func browser(_ browser: NSBrowser, objectValueForItem item: Any?) -> Any? {
        guard let node = item as? Node else { return false }
        return node.item.name
    }
    
    func browser(_ sender: NSBrowser, willDisplayCell cell: Any, atRow row: Int, column: Int) {
        let cell = cell as? NSCell
        
        cell?.menu = cellMenu
    }
    
    func browser(_ browser: NSBrowser, shouldEditItem item: Any?) -> Bool {
        return true
    }
    
    func browser(_ browser: NSBrowser, setObjectValue object: Any?, forItem item: Any?) {
        debugPrint(#function)
        guard let newName = object as? String,
            let node = item as? Node else {
            return
        }
        presenter.renameFile(newName, at: node)
//        browser.reloadColumn(browser.selectedColumn)
    }
}


extension ProjectItem {
    static var empty: ProjectItem {
        return ProjectItem(name: "", children: nil, file: nil)
    }
}

//extension NavigatorViewController: NSMenuDelegate {
//    func menuWillOpen(_ menu: NSMenu) {
//        selectNode()
//
//    }
//}


extension NavigatorViewController: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return presenter.numberOfTargets
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let identifier = tableColumn?.identifier else { return nil }
        
        if let cell = tableView.makeView(withIdentifier: identifier, owner: nil) as? CheckBoxCellView {
            cell.checkBox.state = presenter.isTargetSelected(at: row) ? .on : .off
            cell.checkBox.title = presenter.targetTitle(at: row)
            return cell
        }
    
        return nil
        
    }
    
}
