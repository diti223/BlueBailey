//
//  MVPComponent.swift
//  BlueBailey
//
//  Created by Adrian-Dieter Bilescu on 5/21/19.
//  Copyright © 2019 Bilescu. All rights reserved.
//

import Foundation

enum MVPComponent {
    case connector, viewController, presenter, view, navigation, useCase, presentation, entityGateway, entity
    
    var name: String {
        return String(describing: self).firstLetterUppercased
    }
}
