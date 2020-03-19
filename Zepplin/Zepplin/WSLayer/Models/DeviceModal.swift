//
//  DeviceModal.swift
//  Zepplin
//
//  Created by Mayank Sharma on 06/03/20.
//  Copyright © 2020 Mayank Sharma. All rights reserved.
//

import Foundation
import ObjectMapper


struct NSIError {
    /// Error object
    var error: Error?
    /// Json response of the service
    var response: Any?
}


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
