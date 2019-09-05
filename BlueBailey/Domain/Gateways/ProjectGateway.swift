//
//  ProjectGateway.swift
//  BlueBailey
//
//  Created by Adrian-Dieter Bilescu on 6/26/19.
//  Copyright © 2019 Bilescu. All rights reserved.
//

import Foundation

protocol ProjectGateway {
    func fetchProject(at url: URL) -> Project?
}
