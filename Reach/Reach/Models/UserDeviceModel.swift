//
// UserDeviceModel.swift
//

import Foundation
import ObjectMapper

struct UserDeviceModel: Mappable {
/// UserDeviceModel properties
    /** Username */
    var username: String?
    /** Password */
    var password: String?
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
        username <- map["username"]
        password <- map["password"]
        deviceId <- map["device_id"]
        deviceToken <- map["device_token"]
        deviceType <- map["device_type"]
    }

    func encodeToJSON() -> [String: Any] {
        return self.toJSON()
    }
}
