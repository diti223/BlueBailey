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
    private var project: XcodeProj {
        didSet {
            extractTargets()
        }
    }
    private let projectPath: Path
    private let useCaseFactory: UseCaseFactory
    private var selectedNode: Node! {
        didSet {
            if selectedNode == nil {
                selectedNode = rootNode
            }
        }
    }
    
    private var targets: [Target] = []
    private var selectedPBXTargets: [PBXTarget] {
        return targets.filter { $0.isSelected }.map { $0.target }
    }
    
    var numberOfTargets: Int {
        return targets.count
    }
    
    private let platforms = PlatformFileTemplate.Platform.allCases
    var numberOfPlatforms: Int {
        return platforms.count
    }
    
    private var selectedPlatform: PlatformFileTemplate.Platform
    
    init(view: NavigatorView, navigation: NavigatorNavigation, useCaseFactory: UseCaseFactory, path: Path) throws {
        self.view = view
        self.useCaseFactory = useCaseFactory
        self.navigation = navigation
        self.projectPath = path
        self.project = try XcodeProj(path: path)
        let item = ProjectItem(project: project)
        self.rootNode = Node(item: item)
        self.selectedNode = rootNode
        self.selectedPlatform = platforms[0]
        extractTargets()
        if targets.count > 0 {
            selectTarget(at: 0)
        }
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
        addNewFile(template: ViewControllerFileTemplate(moduleName: moduleName, methodDefinitions: "", project: project, platform: selectedPlatform))
        addNewFile(template: ConnectorFileTemplate(moduleName: moduleName, methodDefinitions: "", project: project, platform: selectedPlatform))
        
        selectedNode = presentationNode
        addNewFile(template: NavigationFileTemplate(moduleName: moduleName, methodDefinitions: "", project: project))
        addNewFile(template: ViewFileTemplate(moduleName: moduleName, project: project))
        addNewFile(template: PresenterFileTemplate(moduleName: moduleName, project: project))
    }
    
    // MARK: - Target data
    
    func targetTitle(at index: Int) -> String {
        return targets[index].name
    }
    
    func isTargetSelected(at index: Int) -> Bool {
        return targets[index].isSelected
    }
    
    func selectTarget(at index: Int) {
        targets[index].isSelected.toggle()
    }
    
    // MARK: - Platform data
    
    func platformTitle(at index: Int) -> String {
        return platforms[index].name
    }
    
    func selectPlatform(at index: Int) {
        self.selectedPlatform = platforms[index]
    }
    
    func openDomainController() {
        //.. get domain node or create it
        navigation.navigateToDomain(delegate: self)
    }
    
    func sortCompileSources() {
        do {
            try selectedPBXTargets.compactMap { try $0.sourcesBuildPhase() }.forEach({ (buildPhase) in
                buildPhase.files?.sort(by: { (file1, file2) -> Bool in
                    return file1.file?.displayName.compare(file2.file?.displayName ?? "") == .orderedAscending
                })
            })
            try commitChanges()
        } catch {
            debugPrint(error)
        }
    }
    
    //MARK: - Private Methods
    
    private func selectLastGroupNode() {
        if let node = lastSelectedGroup() {
            selectNode(node)
        }
    }
    
    private func lastSelectedGroup() -> Node? {
        if (selectedNode?.item.file as? PBXGroup) == nil {
            return selectedNode?.parent
        }
        return selectedNode
    }
    
    private func addNewFileReference(named: String) throws -> Path? {
        selectLastGroupNode()
        let node = selectedNode!
        guard let path = try node.item.file?.fullPath(sourceRoot: projectPath.parent()),
            let fileContainer = selectedNode.item.file as? PBXGroup else {
            return nil
        }
        
        let fileReference = try fileContainer.addFile(at: Path(named), sourceRoot: path, validatePresence: false)
        try selectedPBXTargets.forEach { _ = try $0.sourcesBuildPhase()?.add(file: fileReference) }
        try addFile(reference: fileReference, to: node)
        
        return path
    }
    
    private func addNewGroupReference(named: String) throws -> Path? {
        selectLastGroupNode()
        let node = selectedNode!
        guard let path = try node.item.file?.fullPath(sourceRoot: projectPath.parent()),
            let fileContainer = selectedNode.item.file as? PBXGroup,
            let fileReference = try fileContainer.addGroup(named: named).first else {
                return nil
        }
        try addFile(reference: fileReference, to: node)
        
        return (path + named)
    }
    
    private func addNewGroupReference(at node: Node, named: String) throws -> Path? {
        selectNode(node)
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
    
    // MARK: - Targets
    
    private func extractTargets() {
        targets = project.pbxproj.nativeTargets.map { Target(target: $0) }.sorted(by: { (target1, target2) -> Bool in
            return target1.name < target2.name
        })
    }
    
    private func firstSelectedNode() -> Node {
        var node: Node = selectedNode
        while let parent = node.parent,
            parent != rootNode {
            node = parent
        }
        return node
    }
}


extension NavigatorPresenter: DomainPresenterDelegate {
    func beginProjectUpdates() {
        
    }
    
    func endProjectUpdates() {
        do { try commitChanges() }
        catch { debugPrint(error) }
    }
    
    func createFile(_ name: String, withContent content: String, atRelativePath relativePath: String) {
        do {
            selectNode(firstSelectedNode())
            let firstNodeName = selectedNode.item.name
            let startPath = projectPath.parent() + firstNodeName
            let completePath = (startPath) + relativePath
            createGroups(groupsPath: relativePath, from: <#T##Path#>)
            let relativeComponents = relativePath.components(separatedBy: "/")
            
            try completePath.mkpath()
            let filePath = (projectPath + name)
            if !filePath.exists {
                try (projectPath + name).write(content)
            }
            
        } catch {
            debugPrint("Save file error \(error)")
        }
    }
    
    private func createGroups(groupsPath: String, from path: Path) {
        groupsPath.components(separatedBy: "/").forEach { (groupPath) in
            <#code#>
        }
        addNewGroupReference(named: <#T##String#>)
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

//MARK: - FileTemplate


extension XcodeProjFileTemplate {
    static func empty(project: XcodeProj) -> FileTemplate {
        return namedEmpty(name: "FileName", project: project)
    }
    
    static func namedEmpty(name: String, project: XcodeProj) -> FileTemplate {
        return XcodeProjFileTemplate(fileName: name, fileExtension: "swift", project: project, frameworks: ["Foundation"], fileType: .none)
    }
}

class Target {
    let target: PBXTarget
    var name: String {
        return target.name
    }
    
    var isSelected = false
    
    init(target: PBXTarget) {
        self.target = target
    }
}

extension PBXFileElement {
    var displayName: String {
        return name ?? path ?? ""
    }
}
