//
// Created by Adrian Bilescu on 20/10/2019.
// Copyright (c) 2019 Bilescu. All rights reserved.
//

import XcodeProj

extension Group {
    init?(pbxFileElement: PBXFileElement) {
        guard let pbxGroup = pbxFileElement as? PBXGroup,
              let name = pbxGroup.elementName else {
            return nil
        }
        let subGroups = pbxGroup.children.compactMap { Group(pbxFileElement: $0) }
        let files = pbxGroup.children.compactMap { File(sourceFile: $0) }
        self.init(name: name, files: files, groups: subGroups)
    }
}

extension PBXFileElement {
    var elementName: String? {
        return name ?? path
    }
}
