//
//  Enums.swift
//  DITY
//

import Foundation
struct Enums {

    // user type On basis of logged in
    enum CategoryType: Int {
        case none = 0
        case first = 1
        case second = 2
        case third = 3

    }
    ///   device selection IOS=2, ANDROID=1, Admin=3
    enum DeviceType: Int {
        case iOS = 2
    }
    
    // Version Type
    enum VersionType: Int {
        case VERSION_NO_UPGRADE = 0
        case VERSION_UPGRADE_AVAILABLE = 1
        case VERSION_NOT_SUPPORTED = 2
    }

}
