//
//  String+Extension.swift
//  BlueBailey
//
//  Created by Adrian Bilescu on 24/05/2019.
//  Copyright © 2019 Bilescu. All rights reserved.
//

import Foundation

extension String {
    var firstLetterUppercased: String {
        guard let firstLetter = self.first else { return uppercased()}
        let substring = String(dropFirst())
        return firstLetter.uppercased() + substring
    }
    
    var firstLetterLowercased: String {
        guard let firstLetter = self.first else { return lowercased()}
        let substring = String(dropFirst())
        return firstLetter.lowercased() + substring
    }
}
