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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
        browser.takesTitleFromPreviousColumn = true
        browser.allowsMultipleSelection = true
    }
    
}


extension NavigatorViewController: NavigatorView {
    func displayProject(named: String) {
        browser.delegate = self
    }
}

extension NavigatorViewController: NSBrowserDelegate {
    
    func browser(_ sender: NSBrowser, isColumnValid column: Int) -> Bool {
        return true
    }
    
    func browser(_ sender: NSBrowser, numberOfRowsInColumn column: Int) -> Int {
        return 5
    }
    
    func browser(_ browser: NSBrowser, child index: Int, ofItem item: Any?) -> Any {
        debugPrint(#function)
        return item
    }
    
    func browser(_ browser: NSBrowser, isLeafItem item: Any?) -> Bool {
        debugPrint(#function)
        return true
    }
    
    func browser(_ browser: NSBrowser, objectValueForItem item: Any?) -> Any? {
        debugPrint(#function)
        return "What do we say to death?"
    }
    
//    func browser(_ browser: NSBrowser, shouldShowCellExpansionForRow row: Int, column: Int) -> Bool {
//        return true
//    }
    
    func browser(_ sender: NSBrowser, willDisplayCell cell: Any, atRow row: Int, column: Int) {
        let cell = cell as? NSBrowserCell
        cell?.title = "What do we say to death?"
        debugPrint(#function, cell?.title, row, column)
    }
    

//    func browser(_ sender: NSBrowser, selectCellWith title: String, inColumn column: Int) -> Bool {
//        return true
//    }
}
