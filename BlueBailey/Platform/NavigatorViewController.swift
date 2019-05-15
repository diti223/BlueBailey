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
    
    var presenter: NavigatorPresenter!
    let manager = FileManager.default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
//        browser.takesTitleFromPreviousColumn = true
        browser.allowsMultipleSelection = true
    }
    
    @IBAction func addNewFile(sender: NSButton) {
        let column = browser.selectedColumn
        let row = browser.selectedRow(inColumn: column)
        guard let item = browser.item(atRow: row, inColumn: column) as? ProjectItem else { return }
        presenter.addNewFile(at: item)
    }
}

extension NavigatorViewController: NavigatorView {
    func displayProject(named: String) {
//        browser.delegate = self
        view.window?.title = named
    }
}

extension URL {
    
    func isDirectory() -> Bool {
        return (try? resourceValues(
            forKeys: [.isDirectoryKey]
            ))?.isDirectory ?? false
    }
    
    func fileExists() -> Bool {
        let fileman = FileManager.default
        return fileman.fileExists(atPath: self.path)
    }
    
    var fileIcon : NSImage {
        return (try? resourceValues(
            forKeys: [.effectiveIconKey]
            ))?.effectiveIcon as? NSImage ?? NSImage()
    }
}

extension NavigatorViewController: NSBrowserDelegate {
    
    func rootItem(for browser: NSBrowser) -> Any? {
        return presenter.selectedItem
    }

    func browser(_ browser: NSBrowser, numberOfChildrenOfItem item: Any?) -> Int {
        guard let item = item as? ProjectItem, let children = item.children else { return 0 }
        return children.count
    }


    func browser(_ browser: NSBrowser, child index: Int, ofItem item: Any?) -> Any {
        guard let item = item as? ProjectItem, let children = item.children else { return ProjectItem.empty }
        return children[index]
    }


    func browser(_ browser: NSBrowser, isLeafItem item: Any?) -> Bool {
        guard let item = item as? ProjectItem else { return false }
        return item.children == nil
    }


    func browser(_ browser: NSBrowser, objectValueForItem item: Any?) -> Any? {
        guard let item = item as? ProjectItem else { return false }
        return item.name
    }
    
    
}

class FileCell: NSBrowserCell {
    override init(imageCell i: NSImage?) {
        super.init(imageCell: i)
    }
    
    override init(textCell s: String) {
        super.init(textCell: s)
    }
    
    required init(coder c: NSCoder) {
        super.init(coder: c)
    }
}

extension URL {
    
    //.. other extension properties and functions
    
    var smallFileIcon: NSImage{
        let icon : NSImage = fileIcon
        icon.size = NSMakeSize(16.0, 16.0)
        return icon
    }
}

extension ProjectItem {
    static var empty: ProjectItem {
        return ProjectItem(name: "", children: nil, file: nil)
    }
}
