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
            let fileName = "FileName.swift"
            guard let path = try addNewFileReference(named: fileName) else { return }
            try createNewFile(named: fileName, at: path)

        } catch {
            debugPrint(error)
        }
    }
    
    func addNewFolder() {
        do {
            let folderName = "Group"
            guard let path = try addNewGroupReference(named: folderName) else { return }
            try path.mkdir()
            
        } catch {
            debugPrint(error)
        }
    }
    
    func refreshProject() {
        do {
            self.project = try XcodeProj(path: projectPath)
            let item = ProjectItem(project: project)
            self.rootNode = Node(item: item)
            self.selectedNode = rootNode
            view?.reloadAll()
        }
        catch {
            debugPrint(error)
        }
    }
    
    private func selectFirstGroupNode() {
        if (selectedNode?.item.file as? PBXGroup) == nil {
            selectedNode = selectedNode?.parent
        }
    }
    
    private func addNewFileReference(named: String) throws -> Path? {
        selectFirstGroupNode()
        let node = selectedNode!
        guard let path = try node.item.file?.fullPath(sourceRoot: projectPath.parent()),
            let fileContainer = selectedNode.item.file as? PBXGroup else {
            return nil
        }
        
        let fileReference = try fileContainer.addFile(at: Path(named), sourceRoot: path, validatePresence: false)
        try addFile(reference: fileReference, to: node)
        
        return path
    }
    
    private func addNewGroupReference(named: String) throws -> Path? {
        selectFirstGroupNode()
        let node = selectedNode!
        guard let path = try node.item.file?.fullPath(sourceRoot: projectPath.parent()),
            let fileContainer = selectedNode.item.file as? PBXGroup,
            let fileReference = try fileContainer.addGroup(named: named).first else {
                return nil
        }
        try addFile(reference: fileReference, to: node)
        
        return (path + named)
    }
    
    private func addFile(reference: PBXFileElement, to node: Node) throws {
        let newNode = Node(item: ProjectItem(file: reference))
        node.addChild(newNode)
        addedNewNode(at: node.index)
        try commitChanges()
    }
    
    @discardableResult
    private func createNewFile(named fileName: String, at path: Path) throws -> Path {
        let newFilePath = path + fileName
        try newFilePath.write(FileTemplate(fileName: fileName, project: project, frameworks: ["Foundation", "XcodeProj", "PathKit"], fileType: .class).string)
        return newFilePath
    }
    
//    private func createFolder(named: String, at path: Path) throws {
//        try (path + named).mkdir()
//    }
    
    func renameFile(_ name: String, at node: Node) {
        do {
            guard let fullPath = try node.item.file?.fullPath(sourceRoot: projectPath.parent()) else {
                return
            }
            let newPath = fullPath.parent() + name
            try? fullPath.move(newPath)
            
            try node.renameFileReference(name, sourceRoot: newPath)
            view?.reloadCurrentSection()
            try commitChanges()
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
            node.removeFileReference()
            node.remove()
            try commitChanges()
            deletedNode(at: node.index, parent: parentNode)
        } catch {
            debugPrint(error)
        }
    }
    
    private func commitChanges() throws {
        try project.write(path: projectPath)
    }
    
    
    private func addedNewNode(at index: Int) {
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

extension Node {
    func renameFileReference(_ name: String, sourceRoot: Path) throws {
        if let group = parent?.item.file as? PBXGroup {
            let removedItem = group.children.remove(at: index)
            removedItem.name = name
            removedItem.path = name
            
            group.children.append(removedItem)
            item.name = name
        }
    }
    
    func removeFileReference() {
        if let group = parent?.item.file as? PBXGroup {
            group.children.remove(at: index)
        }
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
