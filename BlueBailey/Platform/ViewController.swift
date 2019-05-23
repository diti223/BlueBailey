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
        ViewController.openNavigatorViewController(at: path)
        view.window?.close()
    }
    
    func openDocument(_ sender: Any?) {
        ViewController.openNewProjectPanel { [weak self] in
            self?.view.window?.close()
        }
    }
    
    @IBAction func doubleClick(_ sender: Any?) {
        openDocument(sender)
    }
    
    
    
    
    static func openNewProjectPanel(completion: (()->())? = nil) {
        guard let window = NSApplication.shared.keyWindow else { return }
        let panel = NSOpenPanel(contentRect: .init(x: 0, y: 0, width: 200, height: 200), styleMask: NSWindow.StyleMask.docModalWindow, backing: .buffered, defer: true)
        panel.allowedFileTypes = ["xcodeproj"]
        panel.allowsMultipleSelection = true
        panel.beginSheetModal(for: window) { (response) in
            guard response == .OK else { return }
            panel.urls.forEach { ViewController.openNavigatorViewController(at: $0.absoluteString) }
            completion?()
        }
    }
    
    static func openInitialViewController() {
        guard let windowController = NSStoryboard(name: "Main", bundle: nil).instantiateInitialController() as? NSWindowController,
            let window = windowController.window else {
            return
        }
        
        NSApplication.shared.addWindowsItem(window, title: "", filename: false)
        window.makeKeyAndOrderFront(nil)
    }
    
    static func openNavigatorViewController(at path: String, from window: NSWindow? = nil) {
        let newWindow: NSWindow
        if let window = window {
             newWindow = window
        } else {
            newWindow = NSWindow()
            newWindow.titlebarAppearsTransparent = false
            newWindow.styleMask.update(with: .resizable)
            newWindow.styleMask.update(with: .closable)
            newWindow.styleMask.update(with: .titled)
            
            if let currentWindow = NSApplication.shared.keyWindow {
                newWindow.setContentSize(currentWindow.frame.size)
                newWindow.setFrameOrigin(currentWindow.frame.origin.applying(.init(translationX: 20, y: -40)))
            }
            let windowController = NSWindowController(window: newWindow)
            windowController.showWindow(nil)
        }
        
        let title = URL(string: path)?.lastPathComponent ?? "New Project"
        newWindow.title = title
        let projectPath = Path(URL(string: path)?.path ?? "")
        
        guard let navigatorViewController = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "NavigatorViewController") as? NavigatorViewController else {
            return
        }
        let connector = NavigatorConnector(useCaseFactory: UseCaseFactory(), projectPath: projectPath)
        try? connector.assemble(viewController: navigatorViewController)
        newWindow.windowController?.contentViewController = navigatorViewController
        
//        NSApplication.shared.addWindowsItem(newWindow, title: title, filename: false)
        
        newWindow.makeKeyAndOrderFront(nil)
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
