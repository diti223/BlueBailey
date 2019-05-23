//
//  PlatformFileTemplate.swift
//  BlueBailey
//
//  Created by Adrian-Dieter Bilescu on 5/21/19.
//  Copyright © 2019 Bilescu. All rights reserved.
//

import Foundation
import XcodeProj

class PlatformFileTemplate: MVPFileTemplate {
    enum Platform: CaseIterable {
        case macOS, iOS, watchOS, tvOS
        
        var defaultFrameworks: [String] {
            switch self {
            case .iOS, .tvOS: return ["UIKit"]
            case .macOS: return ["AppKit"]
            case .watchOS: return ["WatchKit"]
            }
        }
        
        var name: String {
            return String(describing: self)
        }
        
    }
    let platform: Platform
    
    init(moduleName: String, methodDefinitions: String, componentName: String, project: XcodeProj, platform: Platform) {
        self.platform = platform
        super.init(moduleName: moduleName, methodDefinitions: methodDefinitions, componentName: componentName, project: project, frameworks: platform.defaultFrameworks)
    }
}
