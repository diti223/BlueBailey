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
        
        let projectPath = Path(URL(string: path)?.path ?? "")
        
        guard let navigatorViewController = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "NavigatorViewController") as? NavigatorViewController else {
            return
        }
        let connector = NavigatorConnector(useCaseFactory: UseCaseFactory(), projectPath: projectPath)
        try? connector.assemble(viewController: navigatorViewController)
        self.view.window?.contentViewController = navigatorViewController
    }
    
}

protocol DropViewDelegate: class {
    func didDropFile(atPath path: String)
}

class DropView: NSView {
    
    weak var delegate: DropViewDelegate?
    
    override func draggingEnded(_ sender: NSDraggingInfo) {
        debugPrint(#function)
        guard let filePath = sender.draggingPasteboard.propertyList(forType: .fileURL) as? String else { return }
        delegate?.didDropFile(atPath: filePath)
    }
        
}
