//
//  StringTrimExtension.swift
//  ActiveLabel
//
//  Copyright © 2016 Optonaut. All rights reserved.
//

import Foundation

extension String {

    func trim(to maximumCharacters: Int) -> String {
        return "\(self[..<index(startIndex, offsetBy: maximumCharacters)])" + "..."
    }
}
