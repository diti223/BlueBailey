//
//  ViewController.swift
//  BlueBailey
//
//  Created by Adrian-Dieter Bilescu on 5/12/19.
//  Copyright © 2019 Bilescu. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    @IBOutlet weak var dropView: DropView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dropView.wantsLayer = true
        dropView.layer?.borderColor = CGColor.black.copy(alpha: 0.5)
        dropView.layer?.borderWidth = 1
        dropView.layer?.backgroundColor = NSColor.darkGray.cgColor
        dropView.registerForDraggedTypes([NSPasteboard.PasteboardType.fileURL])
    }
    
}

class DropView: NSView {
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        debugPrint(#function)
        return super.draggingEntered(sender)
    }
    
//    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
//        debugPrint(#function)
//        return super.draggingUpdated(sender)
//    }
//
    
    override func draggingEnded(_ sender: NSDraggingInfo) {
        debugPrint(#function)
        guard let filePath = sender.draggingPasteboard.propertyList(forType: .fileURL) as? String else { return }
        guard let url = URL(string: filePath) else { return }
        let contents = try? FileManager.default.contents(atPath: url.path)
        guard let content = try? Data(contentsOf: url) else { return }
        guard let string = String(data: content, encoding: .utf8) else { return }
        
        super.draggingEnded(sender)
    }
}
