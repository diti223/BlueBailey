//
// Created by Adrian Bilescu on 17/10/2019.
// Copyright (c) 2019 Bilescu. All rights reserved.
//

import Foundation
import XcodeProj

public class XcodeProjectManager: ProjectGateway {
    public init() {}
    
    public func open(from url: URL) -> Project? {
        guard let project = try? XcodeProj(pathString: url.path).pbxproj,
            let rootProject = try? project.rootProject() else {
            return nil
        }

        let targets = Set(project.nativeTargets.map { (nativeTarget) -> Target in
            let sourceFiles = (try? nativeTarget.sourceFiles().compactMap { File(sourceFile: $0) }) ?? []
            return Target(name: nativeTarget.name, files: sourceFiles)
        })

        let groups = (try? project.rootGroup()?.children.compactMap { Group(pbxFileElement: $0) }) ?? []
        return Project(name: rootProject.name, targets: targets, groups: groups)
    }
}

extension File {
    init(sourceFile: PBXFileElement) {
        self.name = sourceFile.elementName!
        self.path = sourceFile.fullPath
    }
}

extension PBXFileElement {
    var fullPath: String {
        return fileParentsTree.reversed().compactMap { $0.elementName }.joined(separator: "/")
    }

    var fileParentsTree: [PBXFileElement] {

        guard let parent = self.parent else { return [self] }
        var parentsTree = [self]
        parentsTree.append(contentsOf: parent.fileParentsTree)
        return parentsTree
    }
}
