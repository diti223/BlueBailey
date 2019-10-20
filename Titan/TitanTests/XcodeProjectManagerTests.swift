//
// Created by Adrian Bilescu on 17/10/2019.
// Copyright (c) 2019 Bilescu. All rights reserved.
//

import XCTest
import TitanAPI

class XcodeProjectManagerTests: XCTestCase {
    var sut = XcodeProjectManager()

    func testInvalidURL_ReturnsNoProject() {
        XCTAssertNil(sut.open(from: .url(ofProjectNamed: "NotMyProject")))
    }

    func testValidURL_ReturnsProject() {
        let project = sut.open(from: .venusProjectURL)
        XCTAssertNotNil(project)
    }

    func testOpenVenusProject_ProjectNameIsVenus() {
        let project = openVenusProject()
        XCTAssertEqual("Venus", project.name)

    }

    func testMappingProjectTargets() {
        let project = openVenusProject()

        let expectedTargetNames = Set(["Venus", "Hera", "Hyperion", "HyperionTests", "Apollo", "ApolloTests", "ApolloUITests"])
        let actualTargetNames = Set(project.targets.map { $0.name })
        XCTAssertEqual(expectedTargetNames, actualTargetNames)

    }

    func testFilesNotAddedToTargetDontAppearInTheFilesList() {
        let project = openVenusProject()

        XCTAssertEqual(Set(["main.swift"]), Set(project.targets["Hera"]!.fileNames))
    }

    func testFilesNestedInGroupsShouldAppearInTheFilesList() {
        let project = openVenusProject()

        XCTAssertEqual(Set(["main.swift", "UserPresenter.swift"]), Set(project.targets["Venus"]!.fileNames))
    }

    func testMapHyperionFrameworkTargetFiles() {
        let project = openVenusProject()

        let expectedFileNames = Set(["John", "Tom", "Bill"].map { $0 + ".swift"})
        let actualFileNames = Set(project.targets["Hyperion"]!.fileNames)
        XCTAssertEqual(expectedFileNames, actualFileNames)

    }

    func testOpenVenusProjectMapsGroupNames() {
        let project = openVenusProject()

        let expectedGroups = Set(["Venus", "Hera", "Hyperion", "HyperionTests", "Apo", "ApolloTests", "ApolloUITests", "Products"])
        let actualGroups = Set(project.groups.map { $0.name })

        XCTAssertEqual(expectedGroups, actualGroups)
    }

    func testMappingGroupsShouldExcludeNamesContainingDot() {
        let project = sut.open(from: .url(ofProjectNamed: "Hydra"))
        XCTAssertEqual(["Hydra", "Products"], project?.groups.map { $0.name })
        XCTAssertEqual(["Main.storyboard", "Hydra.xcdatamodeld"], project?.groups["Hydra"]?.groups.map { $0.name })
        XCTAssertEqual(4, project?.targets["Hydra"]?.fileNames.count)
        XCTAssertEqual(["AppDelegate.swift", "ViewController.swift", "Document.swift", "Assets.xcassets", "Info.plist", "Hydra.entitlements"], project?.groups["Hydra"]?.fileNames)
    }

    func testOpenVenusProjectMapsNestedGroupNames() {
        let project = openVenusProject()
        let rootGroup = project.groups["Apo"]!

        let expectedRootSubgroups = Set(["Platform", "Main.storyboard", "Domain", "Document.xcdatamodeld"])
        let actualRootSubgroups = Set(rootGroup.groups.map { $0.name })
        XCTAssertEqual(expectedRootSubgroups, actualRootSubgroups)

        let platformGroup = rootGroup.groups["Platform"]!
        let expectedPlatformSubgroup = Set(["ViewControllers"])
        let actualPlatformSubgroups = Set(platformGroup.groups.map { $0.name })
        XCTAssertEqual(expectedPlatformSubgroup, actualPlatformSubgroups)
    }

    //MARK: - Helper methods
    private func openVenusProject() -> Project {
        return sut.open(from: .venusProjectURL)!
    }
}

private extension URL {
    static var venusProjectURL: URL {
        return url(ofProjectNamed: "Venus")
    }

    static func url(ofProjectNamed projectName: String) -> URL {
        return Bundle.testBundle.resourceURL!.appendingPathComponent("Projects.bundle/\(projectName).xcodeproj")
    }
}
private extension Bundle {
    static var testBundle: Bundle {
        return Bundle(for: XcodeProjectManagerTests.self)
    }
}

/*
XCTAssertEqual failed: ("
Group(name: "Apo", fileNames: [], groups: [TitanTests.Group(name: "Platform", fileNames: [], groups: [TitanTests.Group(name: "ViewControllers", fileNames: [], groups: [])]), TitanTests.Group(name: "Domain", fileNames: [], groups: []), TitanTests.Group(name: "Main.storyboard", fileNames: [], groups: []), TitanTests.Group(name: "Document.xcdatamodeld", fileNames: [], groups: [])])") is not equal to ("
Group(name: "Apo", fileNames: ["Assets.xcassets", "Info.plist", "Apollo.entitlements"], groups: [TitanTests.Group(name: "Platform", fileNames: ["AppDelegate.swift", "Document.swift"], groups: [TitanTests.Group(name: "ViewControllers", fileNames: ["ViewController.swift"], groups: [])]), TitanTests.Group(name: "Domain", fileNames: ["User.swift"], groups: []), TitanTests.Group(name: "Main.storyboard", fileNames: ["Base.lproj/Main.storyboard"], groups: []), TitanTests.Group(name: "Document.xcdatamodeld", fileNames: ["Document.xcdatamodel"], groups: [])])")
*/
