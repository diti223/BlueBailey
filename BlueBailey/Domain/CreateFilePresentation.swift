//
//  CreateFilePresentation.swift
//  BlueBailey
//
//  Created by Adrian-Dieter Bilescu on 5/31/19.
//  Copyright © 2019 Bilescu. All rights reserved.
//

import Foundation

protocol CreateFilePresentation: class {
    func templateNotFound()
    func templateFileError(error: Error)
    func handleCompletedFile(named: String, content: String, path: String)
}
