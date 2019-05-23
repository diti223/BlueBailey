//
//  FileName.swift
//  BlueBailey
//
//  Created by Adrian-Dieter Bilescu on 5/21/19
//  Copyright © 2019 Bilescu. All rights reserved.
//

import Foundation
import XcodeProj

class ViewControllerFileTemplate: PlatformFileTemplate {
    static let viewDidLoadMethod: String =
    """
        override func viewDidLoad() {
            super.viewDidLoad
        }
    """
    init(moduleName: String, methodDefinitions: String = ViewControllerFileTemplate.viewDidLoadMethod, project: XcodeProj, platform: Platform) {
        super.init(moduleName: moduleName, methodDefinitions: methodDefinitions, componentName: MVPComponent.viewController.name, project: project, platform: platform)
        self.fileType = .class
    }
    
    override var string: String {
        let viewControllerClass = "\(platform.viewControllerName)"
        let viewInterfaceName = "\(moduleName)\(MVPComponent.view.name)"
        let presenterName = "\(moduleName)\(MVPComponent.presenter.name)"
        return super.string +
        """
        
        \(String.init(describing: fileType)) \(fileName): \(viewControllerClass) {
            var presenter: \(presenterName)!
        \(methodDefinitions)
        }
        
        \(String.init(describing: FileType.extension)) \(fileName): \(viewInterfaceName) {
            
        }
        
        """
    }
}

extension ViewControllerFileTemplate.Platform {
    var viewControllerName: String {
        switch self {
        case .iOS, .tvOS: return "UIViewController"
        case .macOS: return "NSViewController"
        case .watchOS: return "WKInterfaceController"
        }
    }
}
