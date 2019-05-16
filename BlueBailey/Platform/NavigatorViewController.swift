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
    }
    
    @IBAction func addNewFile(sender: Any) {
        let column = browser.selectedColumn
        let row = browser.selectedRow(inColumn: column)
        guard let item = browser.item(atRow: row, inColumn: column) as? ProjectItem else { return }
        presenter.addNewFile(at: item)
        browser.editItem(at: IndexPath(item: 0, section: 0), with: nil, select: true)
    }
    
    @IBAction func deleteFile(sender: Any) {
        
    }
    
    @IBAction func renameFile(sender: Any) {
        
    }
    
    
}

extension NavigatorViewController: NavigatorView {
    func displayProject(named: String) {
        view.window?.title = named
    }
    
    func reloadItems(in section: Int) {
        browser.reloadColumn(section)
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
        guard let node = item as? Node else { return Node(item: .empty, index: 0) }
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
}


extension ProjectItem {
    static var empty: ProjectItem {
        return ProjectItem(name: "", children: nil, file: nil)
    }
}
