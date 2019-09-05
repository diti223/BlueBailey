//
//  ProjectStore.swift
//  Nodes
//
//  Created by Adrian-Dieter Bilescu on 6/24/19.
//  Copyright © 2019 Bilescu. All rights reserved.
//

import Foundation
import XcodeProj

class ProjectStore: ProjectGateway {
    func fetchProject(at url: URL) -> Project? {
        return Project(name: "")
    }
}
