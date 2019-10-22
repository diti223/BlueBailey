//
// Created by Adrian Bilescu on 16/10/2019.
// Copyright (c) 2019 Bilescu. All rights reserved.
//

import Foundation

public class ProjectLoader {
    public let url: URL
    public let prejectGateway: ProjectGateway

    public init(url: URL, projectGateway: ProjectGateway) {
        self.url = url
        self.prejectGateway = projectGateway
    }

    public func load() throws -> Project {
        guard let project = prejectGateway.open(from: url) else {
            throw NSError(domain: "com.titan", code: 0)
        }
        return  project
    }
}
