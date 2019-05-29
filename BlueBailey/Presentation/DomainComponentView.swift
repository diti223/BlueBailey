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
    func updateSuggestedNamePrefix(_ prefix: String)
    func updateSuggestedNameSuffix(_ suffix: String)
    func displayName()
}

protocol DomainComponentActionView: DomainComponentView {
    func displayAddAction()
    func displayRemoveAction()
}
