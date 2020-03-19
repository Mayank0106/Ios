//
//  AppUpdateInfo.swift
//  
//

import Foundation
import ObjectMapper

struct VersionUpdate: Mappable {
    /// VerificationCode properties
    /** Is app update aviable */
    var latest_version: String?
    /** is force updation of app. */
    var version_check: Int?

    init() {
    }

    init?(map: Map) {
    }

    mutating func mapping(map: Map) {
        latest_version <- map["latest_version"]
        version_check <- map["version_check"]
    }

    func encodeToJSON() -> [String: Any] {
        return self.toJSON()
    }
}
