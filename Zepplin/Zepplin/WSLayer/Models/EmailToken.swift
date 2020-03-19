//
// EmailToken.swift
//

import Foundation
import ObjectMapper

struct EmailToken: Mappable {
/// EmailToken properties
    /** get the email verification code */
    var otp: String?
    /** email id */
    var email: String?

    init() {
    }

    init?(map: Map) {
    }

    mutating func mapping(map: Map) {
        otp <- map["otp"]
        email <- map["email"]
    }

    func encodeToJSON() -> [String : Any] {
        return self.toJSON()
    }
}
