//
//  ViewController.swift
//  BlueBailey
//
//  Created by Adrian-Dieter Bilescu on 5/12/19.
//  Copyright © 2019 Bilescu. All rights reserved.
//

import Cocoa
import PathKit
import XcodeProj

class ViewController: NSViewController, DropViewDelegate {
    @IBOutlet weak var dropView: DropView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dropView.wantsLayer = true
        dropView.layer?.borderColor = CGColor.black.copy(alpha: 0.5)
        dropView.layer?.borderWidth = 1
        dropView.layer?.backgroundColor = NSColor.darkGray.cgColor
        dropView.registerForDraggedTypes([NSPasteboard.PasteboardType.fileURL])
        dropView.delegate = self
        
    }
    
    func didDropFile(atPath path: String) {
        
        var path = path
        path.removeFirst(7)
        
        guard let navigatorViewController = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "NavigatorViewController") as? NavigatorViewController else {
            return
        }
        let connector = NavigatorConnector(useCaseFactory: UseCaseFactory(), projectPath: Path(path))
        try? connector.assemble(viewController: navigatorViewController)
//        self.presentAsModalWindow(navigatorViewController)
//        self.view.window?.contentView = navigatorViewController.view
        self.view.window?.contentViewController = navigatorViewController
//        self.view.removeFromSuperview()
//        dismiss(self)
    }
    
    
}

protocol DropViewDelegate: class {
    func didDropFile(atPath path: String)
}

class DropView: NSView {
    
    weak var delegate: DropViewDelegate?
    
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
//        guard let url = URL(string: filePath) else { return }
//        let contents = try? FileManager.default.contents(atPath: url.path)
//        guard let content = try? Data(contentsOf: url) else { return }
//        guard let string = String(data: content, encoding: .utf8) else { return }
        delegate?.didDropFile(atPath: filePath)
        
        
//        super.draggingEnded(sender)
    }
    
    
}
