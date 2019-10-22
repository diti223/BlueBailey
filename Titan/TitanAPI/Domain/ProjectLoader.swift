//
// Created by Adrian Bilescu on 16/10/2019.
// Copyright (c) 2019 Bilescu. All rights reserved.
//

import Foundation

public class ProjectLoader {
    public let url: URL
    public let projectManager: ProjectManager

    public init(url: URL, projectManager: ProjectManager) {
        self.url = url
        self.projectManager = projectManager
    }

    public  func load() throws -> Project {
        guard let project = projectManager.open(from: url) else {
            throw NSError(domain: "com.titan", code: 0)
        }
        return  project
    }
}
