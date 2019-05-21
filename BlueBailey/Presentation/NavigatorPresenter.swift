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
        addNewEmptyFile()
    }
    
    private func addNewEmptyFile() {
        addNewFile(template: XcodeProjFileTemplate.empty(project: project))
    }
    
    private func addNewEmptyFile(named: String) {
        addNewFile(template: XcodeProjFileTemplate.namedEmpty(name: named, project: project))
    }
    
    private func addNewFile(template: FileTemplate) {
        do {
            guard let path = try addNewFileReference(named: template.completeName) else { return }
            try createNewFile(at: path, template: template)
            
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
    
    func createMVPFiles(moduleName: String) {
        guard let platformNode = selectedNode["Platform"],
            let presentationNode = selectedNode["Presentation"] else {
                return
        }
        selectedNode = platformNode
        [MVPComponent.connector, .viewController].forEach {
            addNewEmptyFile(named: "\(moduleName)\($0.name)")
        }
        selectedNode = presentationNode
        [MVPComponent.view, .navigation].forEach {
            addNewEmptyFile(named: "\(moduleName)\($0.name)")
        }
        addNewFile(template: PresenterFileTemplate(moduleName: moduleName, project: project))
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
    private func createNewFile(at path: Path, template: FileTemplate) throws -> Path {
        let newFilePath = path + template.completeName
        try newFilePath.write(template.string)
        return newFilePath
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

extension FileTemplate {
    var completeName: String {
        return fileName + ".\(fileExtension)"
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
    
    subscript(name: String) -> Node? {
        get {
            return children.first(where: { $0.item.name == name })
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
    let fileType: FileType
    
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
        return
"""
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
        return
"""
\(topFileComment)

\(frameworksImports)
"""
    }
    
    var string: String {
        return beforeClassDefinition
    }
}

extension XcodeProjFileTemplate {
    static func empty(project: XcodeProj) -> FileTemplate {
        return namedEmpty(name: "FileName", project: project)
    }
    
    static func namedEmpty(name: String, project: XcodeProj) -> FileTemplate {
        return XcodeProjFileTemplate(fileName: name, fileExtension: "swift", project: project, frameworks: ["Foundation"], fileType: .none)
    }
}

class XcodeProjFileTemplate: FileTemplate {
    init(fileName: String, fileExtension: String, project: XcodeProj, frameworks: [String], fileType: FileType) {
        let company = project.pbxproj.rootObject?.attributes["ORGANIZATIONNAME"] as? String ?? ""
        let projectName = project.pbxproj.rootObject?.name ?? ""
        super.init(fileName: fileName, fileExtension: fileExtension, project: projectName, author: NSFullUserName(), date: .init(), company: company, frameworks: frameworks, fileType: fileType)
    }
}


private enum MVPComponent {
    case connector, viewController, presenter, view, navigation, useCase, presentation, entityGateway, entity
    
    var name: String {
        var componentName = String.init(describing: self)
        let firstLetter = componentName.removeFirst().uppercased()
        return firstLetter + componentName
    }
}

class MVPFileTemplate: XcodeProjFileTemplate {
    let moduleName: String
    let methodDefinitions: String
    
    init(moduleName: String, methodDefinitions: String, componentName: String, project: XcodeProj) {
        self.methodDefinitions = methodDefinitions
        self.moduleName = moduleName
        super.init(fileName: "\(moduleName)\(componentName)", fileExtension: "swift", project: project, frameworks: ["Foundation"], fileType: .class)
    }
}



class PresenterFileTemplate: MVPFileTemplate {
    static let viewDidLoadMethod: String =
    """
    func viewDidLoad() {

    }
    """
    init(moduleName: String, methodDefinitions: String = PresenterFileTemplate.viewDidLoadMethod, project: XcodeProj) {
        super.init(moduleName: moduleName, methodDefinitions: methodDefinitions, componentName: MVPComponent.presenter.name, project: project)
    }
    
    override var string: String {
        let viewInterfaceName = "\(moduleName)\(MVPComponent.view.name)"
        let navigationInterfaceName = "\(moduleName)\(MVPComponent.navigation.name)"
        return super.string +
        """
        \(String.init(describing: fileType)) \(fileName) {
        weak var view: \(viewInterfaceName)?
        let navigation: \(navigationInterfaceName)
        
        init(view: \(viewInterfaceName), navigation: \(navigationInterfaceName)) {
        self.view = view
        self.navigation = navigation
        }
        
        \(methodDefinitions)
        }
        
        """
    }
}
