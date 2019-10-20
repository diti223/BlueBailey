//
// Created by Adrian Bilescu on 17/10/2019.
// Copyright (c) 2019 Bilescu. All rights reserved.
//

import Foundation
import XcodeProj

public class XcodeProjectManager: ProjectManager {
    public init() {}
    
    public func open(from url: URL) -> Project? {
        guard let project = try? XcodeProj(pathString: url.path).pbxproj,
            let rootProject = try? project.rootProject() else {
            return nil
        }

        let targets = Set(project.nativeTargets.map { (nativeTarget) -> Target in
            let sourceFileNames: [String] = (try? nativeTarget.sourceFiles().compactMap { $0.elementName }) ?? []
            return Target(name: nativeTarget.name, fileNames: sourceFileNames)
        })

        let groups = (try? project.rootGroup()?.children.compactMap { Group(pbxFileElement: $0) }) ?? []
        return Project(name: rootProject.name, targets: targets, groups: groups)
    }
}
