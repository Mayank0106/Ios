//
// DeviceInfo.swift
//

import Foundation
import ObjectMapper

struct DeviceInfo: Mappable {
/// DeviceInfo properties
    /** Device Type */
    var deviceType: Int?
    /** Device Token */
    var deviceToken: String?
    /** Device Id */
    var deviceId: String?
    /** Device OS */
    var deviceOS: String?

    init() {
    }

    init?(map: Map) {
    }

    mutating func mapping(map: Map) {
        deviceType <- map["device_type"]
        deviceToken <- map["device_token"]
        deviceId <- map["device_id"]
        deviceOS <- map["device_os"]
    }

    func encodeToJSON() -> [String: Any] {
        return self.toJSON()
    }
}
