//
//  NavigatorPresenter.swift
//  BlueBailey
//
//  Created by Adrian-Dieter Bilescu on 5/14/19.
//  Copyright © 2019 Bilescu. All rights reserved.
//

import Foundation
import XcodeProj
import PathKit

class NavigatorPresenter {
    private weak var view: NavigatorView?
    private let navigation: NavigatorNavigation
    private let project: XcodeProj
    private let projectPath: Path
    private let useCaseFactory: UseCaseFactory
    var rootNode: Node
    
    init(view: NavigatorView, navigation: NavigatorNavigation, useCaseFactory: UseCaseFactory, path: Path) throws {
        self.view = view
        self.useCaseFactory = useCaseFactory
        self.navigation = navigation
        self.projectPath = path
        self.project = try XcodeProj(path: path)
        let item = ProjectItem(project: project)
        self.rootNode = Node(item: item, index: 0)
        
    }
    
    func viewDidLoad() {
        view?.displayProject(named: project.pbxproj.rootObject?.name ?? "Project")
    }
    
    func addNewFile(at node: Node) {
        do {
            let item = node.item
            guard let path = try item.file?.fullPath(sourceRoot: projectPath.parent()) else { return }
            
            let newFilePath = path + "FileName.swift"
            try newFilePath.write(FileTemplate(fileName: "FileName", project: "TestProject", author: "Adrian Bilescu", date: .init(), company: "Bilescu", frameworks: ["Foundation", "XcodeProj", "PathKit"], fileType: .class).string)
            
            //        let newFile = PBXFileElement.init(sourceTree: PBXSourceTree.group, path: path, name: "Filename.swift", includeInIndex: nil, usesTabs: nil, indentWidth: nil, tabWidth: nil, wrapsLines: nil)
            _ = try (item.file as? PBXGroup)?.addFile(at: newFilePath, sourceRoot: newFilePath)
            
            try project.write(path: projectPath)
        } catch {
            debugPrint(error)
        }
    }
    
}

struct ProjectItem {
    let name: String
    let children: [ProjectItem]?
    let file: PBXFileElement?
}

class Node {
    var parent: Node? = nil
    var children: [Node]
    let item: ProjectItem
    let index: Int
    
    init(item: ProjectItem, parent: Node? = nil, index: Int) {
        
        self.item = item
        self.parent = parent
        self.children = item.children?.enumerated().map { return  Node(item: $0.element, index: $0.offset) } ?? []
        self.index = index
        self.children.forEach { $0.parent = self }
    }
    
    var siblingsCount: Int {
        return parent?.children.count ?? 0
    }
    
    subscript(indexes: [Int]) -> Node? {
        get {
            return indexes.reduce(self) { (node, index) -> Node in
                return node.children[index]
            }
        }
        set {
            guard let lastIndex = indexes.last else { return }
            guard let newValue = newValue else {
                self[indexes]?.parent?.children.remove(at: lastIndex)
                return
            }
            self.children.insert(newValue, at: lastIndex)
        }
    }
    
    func addChild(_ node: Node) {
        self.children.append(node)
    }
}

extension ProjectItem {
    init(project: XcodeProj) {
        name = project.pbxproj.rootObject?.name ?? "-"
        if let rootGroup = try? project.pbxproj.rootGroup() {
            children = rootGroup.children.map({ (fileElement) -> ProjectItem in
                return ProjectItem(file: fileElement)
            })
            file = rootGroup
        } else {
            children = nil
            file = nil
        }
    }
    
    init(group: PBXGroup) {
        name = (group.path ?? group.name) ?? "-"
        children = group.children.map { ProjectItem(file: $0) }
        file = group
    }
    
    init(file: PBXFileReference) {
        self.init(name: file.path ?? "-", children: nil, file: file)
    }
    
    init(file: PBXFileElement) {
        if let group = file as? PBXGroup {
            self.init(group: group)
        } else if let fileReference = file as? PBXFileReference {
            self.init(file: fileReference)
        } else {
            self.init(name: file.path ?? "-", children: nil, file: file)
        }
    }
}

struct FileTemplate {
    enum FileType {
        case `enum`, `struct`, `class`, `protocol`
    }
    let fileName: String
    let project: String
    let author: String
    let date: Date
    let company: String
    let frameworks: [String]
    let fileType: FileType
    
    var string: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        let shortDateString = dateFormatter.string(from: date)
        dateFormatter.dateFormat = "yyyy"
        let yearDateString = dateFormatter.string(from: date)
        let frameworksString = frameworks.map { "import \($0)" }.joined(separator: "\n")
        let templateString = """
//
//  \(fileName)
//  \(project)
//
//  Created by \(author) on \(shortDateString)
//  Copyright © \(yearDateString) \(company). All rights reserved.
//

\(frameworksString)
"""
        return templateString
    }
}
