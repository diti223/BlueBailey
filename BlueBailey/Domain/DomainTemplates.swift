//
//  DomainTemplates.swift
//  BlueBailey
//
//  Created by Adrian-Dieter Bilescu on 6/2/19.
//  Copyright © 2019 Bilescu. All rights reserved.
//

import Foundation

protocol DomainTemplates {
    static var fileName: String { get }
    static var groupPath: String { get }
    var keywords: [String: String] { get }
}
