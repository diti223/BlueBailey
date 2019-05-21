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
    
    var presenter: NavigatorPresenter!
    let manager = FileManager.default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
        browser.allowsMultipleSelection = true
        browser.menu = cellMenu
        cellMenu.delegate = self
    }
    
    @IBAction func addNewFile(sender: Any) {
        presenter.addNewFile()
    }
    
    @IBAction func addNewFolder(sender: Any) {
        presenter.addNewFolder()
    }
    
    @IBAction func deleteFile(sender: Any) {
        presenter.deleteFile()
    }
    
    @IBAction func renameFile(sender: Any) {
        let column = browser.selectedColumn
        let row = browser.selectedRow(inColumn: column)
        let indexPath = IndexPath(item: row, section: column)
        browser.editItem(at: indexPath, with: nil, select: true)
    }
    
    @IBAction func refreshAction(sender: Any) {
        presenter.refreshProject()
    }
    
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

extension NavigatorViewController: NSMenuDelegate {
    func menuWillOpen(_ menu: NSMenu) {
        selectNode()
        
    }
}
