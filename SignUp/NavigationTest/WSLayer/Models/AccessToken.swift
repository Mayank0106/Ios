//
// AccessToken.swift
//

import Foundation
import ObjectMapper

struct AccessToken: Mappable {
/// AccessToken properties
    /** Type of token. */
    var tokenType: String?
    /** Scope of token. */
    var scope: String?
    /** Toeken expiry time (in seconds). */
    var expiresIn: String?
    /** Access Token. */
    var accessToken: String?
    var refreshToken: String?

    init() {
    }
 
    init?(map: Map) {
    }

    mutating func mapping(map: Map) {
        tokenType <- map["token_type"]
        scope <- map["scope"]
        expiresIn <- map["expires_in"]
        accessToken <- map["access_token"]
        refreshToken <- map["refresh_token"]
    }

    func encodeToJSON() -> [String : Any] {
        return self.toJSON()
    }
}
