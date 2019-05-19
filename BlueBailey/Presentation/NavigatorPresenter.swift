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
    var rootNode: Node
    
    private weak var view: NavigatorView?
    private let navigation: NavigatorNavigation
    private var project: XcodeProj
    private let projectPath: Path
    private let useCaseFactory: UseCaseFactory
    private var selectedNode: Node! {
        didSet {
            if selectedNode == nil {
                selectedNode = rootNode
            }
        }
    }
    
    init(view: NavigatorView, navigation: NavigatorNavigation, useCaseFactory: UseCaseFactory, path: Path) throws {
        self.view = view
        self.useCaseFactory = useCaseFactory
        self.navigation = navigation
        self.projectPath = path
        self.project = try XcodeProj(path: path)
        let item = ProjectItem(project: project)
        self.rootNode = Node(item: item)
        self.selectedNode = rootNode
    }
    
    func viewDidLoad() {
        view?.displayProject(named: project.pbxproj.rootObject?.name ?? "Project")
    }
    
    func addNewFile() {
        do {
            guard selectedNode.children.count != 0 else {
                selectedNode = selectedNode.parent
                addNewFile()
                return
            }
            
            guard let path = try selectedNode.item.file?.fullPath(sourceRoot: projectPath.parent()) else {
                    return
            }
            
            let fileContainer = selectedNode.item.file as? PBXGroup
            let fileName = "FileName.swift"
            try createNewFile(named: fileName, at: path)
            
            guard let fileReference = try fileContainer?.addFile(at: Path(fileName), sourceRoot: path, validatePresence: false) else { return }
            try commitChanges()
            let newNode = Node(item: ProjectItem(file: fileReference))
            selectedNode.addChild(newNode)
            addedNewNode(at: selectedNode.index)
        } catch {
            debugPrint(error)
        }
    }
    
    func addNewFolder() {
        
    }
    
    private func addNewFileReference(_ fileReference: PBXFileReference) {
//        do {
//            guard selectedNode?.children.count != 0 else {
//                selectedNode = selectedNode?.parent
//                addNewFile()
//                return
//            }
//
//            guard let node = selectedNode,
//                let path = try node.item.file?.fullPath(sourceRoot: projectPath.parent()) else {
//                    return
//            }
//
//            let fileContainer = node.item.file as? PBXGroup
//            let fileName = "FileName.swift"
//            try createNewFile(named: fileName, at: path)
//
//            guard let addedfileReference = try fileContainer?.addFile(at: Path(fileName), sourceRoot: path, validatePresence: false) else { return }
//            try commitChanges()
//            let newNode = Node(item: ProjectItem(file: fileReference))
//            node.addChild(newNode)
//            addedNewNode(at: node.index)
//        } catch {
//            debugPrint(error)
//        }
    }
    
    @discardableResult
    private func createNewFile(named fileName: String, at path: Path) throws -> Path {
        let newFilePath = path + fileName
        try newFilePath.write(FileTemplate(fileName: fileName, project: project, frameworks: ["Foundation", "XcodeProj", "PathKit"], fileType: .class).string)
        return newFilePath
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
    
    func deleteFile() {
        
        guard let node = selectedNode,
            let fullPath = try? node.item.file?.fullPath(sourceRoot: projectPath.parent()) else {
            return
        }
        let parentNode = node.parent
        
        do {
            try? fullPath.delete()
            if let group = parentNode?.item.file as? PBXGroup {
                group.children.remove(at: node.index)
            }
            node.remove()
            try commitChanges()
            deletedNode(at: node.index, parent: parentNode)
        } catch {
            debugPrint(error)
        }
    }
    
    func refreshProject() {
        do { self.project = try XcodeProj(path: projectPath) }
        catch { debugPrint(error) }
    }
    
    private func commitChanges() throws {
        try project.write(path: projectPath)
    }
    
    
    private func addedNewNode(at index: Int) {
//        selectedNode?.addChild(.init(name: "New Node"))
//        guard let index = selectedNode?.index else { return }
        
        view?.reloadCurrentSection()
        view?.select(row: index)
    }
    
    private func deletedNode(at index: Int, parent: Node?) {
        guard let parentNode = parent else {
            view?.reloadParentSection()
            return
        }
        
        if parentNode.children.count > 0 {
            if index >= parentNode.children.count {
                view?.select(row: parentNode.children.count-1)
            } else {
                view?.select(row: index)
            }
        } else {
            view?.reloadParentSection()
        }
        view?.reloadCurrentSection()
    }
    
    func selectNode(_ node: Node) {
        selectedNode = node
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

class Node: NSObject {
    weak var parent: Node? = nil
    var children: [Node] = [] {
        didSet {
            indexChildren()
        }
    }
    let item: ProjectItem
    var index: Int = 0
    
    init(item: ProjectItem, parent: Node? = nil) {
        self.item = item
        self.parent = parent
        super.init()
        if let children = item.children?.map({ return  Node(item: $0)}) {
            self.addChildren(children)
        }
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
        node.parent = self
    }
    
    func addChildren(_ nodes: [Node]) {
        children = nodes
        nodes.forEach { $0.parent = self }
    }
    
    func remove() {
        parent?.children.remove(at: index)
    }
    
    func indexChildren() {
        self.children.enumerated().forEach { $0.element.index = $0.offset }
    }
}

// MARK: - ProjectItem
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

/// FileTemplate
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
