//
//  DomainComponentView.swift
//  BlueBailey
//
//  Created by Adrian-Dieter Bilescu on 5/27/19.
//  Copyright © 2019 Bilescu. All rights reserved.
//

import Foundation

protocol DomainComponentView: class {
    
}

protocol DomainComponentItemView: DomainComponentView {
    func displayName(_ name: String)
}

protocol DomainComponentNameView: DomainComponentView {
    func displaySuggested(_ name: String)
    
}

protocol DomainComponentActionView: DomainComponentView {
    func displayAddAction(_ shouldDisplay: Bool)
    func displayRemoveAction(_ shouldDisplay: Bool)
}
