//
//  FileName.swift
//  BlueBailey
//
//  Created by Adrian-Dieter Bilescu on 5/21/19
//  Copyright © 2019 Bilescu. All rights reserved.
//

import Foundation
import XcodeProj

class FileTemplate {
    enum FileType {
        case none, `enum`, `struct`, `class`, `protocol`
    }
    let fileName: String
    let fileExtension: String
    let project: String
    let author: String
    let date: Date
    let company: String
    let frameworks: [String]
    var fileType: FileType = .none
    
    init(fileName: String, fileExtension: String, project: String, author: String, date: Date, company: String, frameworks: [String], fileType: FileType) {
        self.fileName = fileName
        self.fileExtension = fileExtension
        self.project = project
        self.author = author
        self.date = date
        self.company = company
        self.frameworks = frameworks
        self.fileType = fileType
    }
    
    
    
    var topFileComment: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        let shortDateString = dateFormatter.string(from: date)
        dateFormatter.dateFormat = "yyyy"
        let yearDateString = dateFormatter.string(from: date)
        return """
        //
        //  \(fileName).\(fileExtension)
        //  \(project)
        //
        //  Created by \(author) on \(shortDateString)
        //  Copyright © \(yearDateString) \(company). All rights reserved.
        //
        """
    }
    
    var frameworksImports: String {
        let frameworksString = frameworks.map { "import \($0)" }.joined(separator: "\n")
        return "\(frameworksString)"
    }
    
    var beforeClassDefinition: String {
        return """
        \(topFileComment)
        
        \(frameworksImports)
        
        """
    }
    
    var string: String {
        return beforeClassDefinition
    }
}

class XcodeProjFileTemplate: FileTemplate {
    init(fileName: String, fileExtension: String, project: XcodeProj, frameworks: [String], fileType: FileType) {
        let company = project.pbxproj.rootObject?.attributes["ORGANIZATIONNAME"] as? String ?? ""
        let projectName = project.pbxproj.rootObject?.name ?? ""
        super.init(fileName: fileName, fileExtension: fileExtension, project: projectName, author: NSFullUserName(), date: .init(), company: company, frameworks: frameworks, fileType: fileType)
    }
}
