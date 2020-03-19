//
//  CameraExtensions.swift
//

import Foundation
// Array Extension
extension Array {
    func isArrayIndexWithinBound(index: Int) -> Bool {
        if index >= 0 && self.count > index {
            return true
        }

        return false
    }
}
