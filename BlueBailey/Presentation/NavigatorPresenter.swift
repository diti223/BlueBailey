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
    var currentItems: [ProjectItem]?
    var selectedItem: ProjectItem? {
        didSet {
            currentItems = selectedItem?.children ?? []
        }
    }
    
    init(view: NavigatorView, navigation: NavigatorNavigation, useCaseFactory: UseCaseFactory, path: Path) throws {
        self.view = view
//        self.project = project
        self.useCaseFactory = useCaseFactory
        self.navigation = navigation
        self.projectPath = path
        self.project = try XcodeProj(path: path)
    }
    
    func viewDidLoad() {
        view?.displayProject(named: project.pbxproj.rootObject?.name ?? "Project")
        self.selectedItem = ProjectItem(project: project)
    }
    
    func addNewFile(at item: ProjectItem) {
        do {
            guard let path = try item.file?.fullPath(sourceRoot: projectPath.parent()) else { return }
            
            let newFilePath = path + "FileName.swift"
            try newFilePath.write("")
            
            //        let newFile = PBXFileElement.init(sourceTree: PBXSourceTree.group, path: path, name: "Filename.swift", includeInIndex: nil, usesTabs: nil, indentWidth: nil, tabWidth: nil, wrapsLines: nil)
            _ = try (item.file as? PBXGroup)?.addFile(at: newFilePath, sourceRoot: newFilePath)
            try project.write(path: projectPath)
        } catch {
            debugPrint(error)
        }
    }
    
    func numberOfItems(at section: Int) -> Int {
        return currentItems?.count ?? 0
    }
    
    func titleOfItem(at index: Int) -> String {
        return currentItems?[index].name ?? "-"
    }
    
    func selectItem(at index: Int) {
        selectedItem = currentItems?[index]
    }
}

struct ProjectItem {
    let name: String
    let children: [ProjectItem]?
    let file: PBXFileElement?
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
        children = group.children.map({ (fileElement) -> ProjectItem in
            return ProjectItem(file: fileElement)
        })
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


