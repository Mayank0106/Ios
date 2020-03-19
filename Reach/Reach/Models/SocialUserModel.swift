//
// SocialUserModel.swift
//

import Foundation
import ObjectMapper

struct SocialUserModel: Mappable {
/// SocialUserModel properties
    /** Full Name */
    var fullname: String?
    /** Snapchat Id */
    var snapchatId: String?
    /** Profile Image */
    var profileImage: String?
    /** Device ID */
    var deviceId: String?
    /** Device Token */
    var deviceToken: String?
    /** Device Type */
    var deviceType: Int?

    init() {
    }

    init?(map: Map) {
    }

    mutating func mapping(map: Map) {
        fullname <- map["fullname"]
        snapchatId <- map["snapchat_id"]
        profileImage <- map["profile_image"]
        deviceId <- map["device_id"]
        deviceToken <- map["device_token"]
        deviceType <- map["device_type"]
    }

    func encodeToJSON() -> [String: Any] {
        return self.toJSON()
    }
}
