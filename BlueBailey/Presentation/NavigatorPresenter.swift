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
            
            let fileName = "FileName.swift"
            let newFilePath = path + fileName
            try newFilePath.write(FileTemplate(fileName: fileName, project: project, frameworks: ["Foundation", "XcodeProj", "PathKit"], fileType: .class).string)
            
            guard let fileReference = try (item.file as? PBXGroup)?.addFile(at: Path(fileName), sourceRoot: path, validatePresence: false) else { return }
            try commitChanges()
            let newNode = Node(item: ProjectItem(file: fileReference), index: node.siblingsCount)
            newNode.parent = node
            newNode.parent?.addChild(newNode)
            
            view?.reloadItems(in: newNode.parentsCount - 1)
        } catch {
            debugPrint(error)
        }
    }
    
    func renameFile(_ name: String, at node: Node) {
        do {
            guard let fullPath = try node.item.file?.fullPath(sourceRoot: projectPath.parent()) else {
                return
            }
            let newPath = fullPath.parent() + name
//            try fullPath.copy(newPath)
//            try fullPath.delete()
            try fullPath.move(newPath)
            node.item.file?.name = name
            try commitChanges()
//            view?.reloadItems(in: node.parentsCount - 1)
        } catch {
            debugPrint(error)
        }
    }
    
    func deleteFile(at node: Node) {
        guard let fullPath = try? node.item.file?.fullPath(sourceRoot: projectPath.parent()) else {
            return
        }
        
        do {
            try? fullPath.delete()
            if let group = node.parent?.item.file as? PBXGroup {
                group.children.removeAll { $0.name == node.item.file?.name }
            }
            node.remove()
            try commitChanges()
            view?.reloadItems(in: node.parentsCount)
        } catch {
            debugPrint(error)
        }
    }
    
    private func commitChanges() throws {
        try project.write(path: projectPath)
    }
    
}

extension FileTemplate {
    init(fileName: String, project: XcodeProj, frameworks: [String], fileType: FileType) {
        let company = project.pbxproj.rootObject?.attributes["ORGANIZATIONNAME"] as? String ?? ""
        let projectName = project.pbxproj.rootObject?.name ?? ""
        self.init(fileName: fileName, project: projectName, author: NSFullUserName(), date: .init(), company: company, frameworks: frameworks, fileType: fileType)
    }
}

class ProjectItem {
    var name: String
    var children: [ProjectItem]?
    var file: PBXFileElement?
    
    init(name: String, children: [ProjectItem]?, file: PBXFileElement?) {
        self.name = name
        self.children = children
        self.file = file
    }
}

class Node: CustomDebugStringConvertible {
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
        guard let parent = parent else { return 0 }
        return parent.children.count - 1
    }
    
    var parentsCount: Int {
        guard let parent = parent else { return 0 }
        return parent.parentsCount + 1
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
    
    func remove() {
        self.parent?.children.removeAll(where: { $0.item.name == self.item.name })
    }
    
    var debugDescription: String {
        return """
        name: \(item.name)
        children: \(children.map { $0.debugDescription }.joined(separator: "\n") )
        """
    }
}

extension ProjectItem {
    convenience init(project: XcodeProj) {
        let name = project.pbxproj.rootObject?.name ?? "-"
        let children: [ProjectItem]?
        let file: PBXFileElement?
        if let rootGroup = try? project.pbxproj.rootGroup() {
            children = rootGroup.children.map({ (fileElement) -> ProjectItem in
                return ProjectItem(file: fileElement)
            })
            file = rootGroup
        } else {
            children = nil
            file = nil
        }
        self.init(name: name, children: children, file: file)
    }
    
    convenience init(group: PBXGroup) {
        let name = (group.path ?? group.name) ?? "-"
        let children = group.children.map { ProjectItem(file: $0) }
        let file = group
        self.init(name: name, children: children, file: file)
    }
    
    convenience init(file: PBXFileReference) {
        self.init(name: file.path ?? "-", children: nil, file: file)
    }
    
    convenience init(file: PBXFileElement) {
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
