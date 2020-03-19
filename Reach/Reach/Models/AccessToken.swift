//
//  AccessToken.swift

import Foundation
import ObjectMapper

class AccessToken: NSObject, Mappable, NSCoding {
    /// AccessToken properties
    /** Access token. */
    var accessToken: String?
    /** Token type. */
    var tokenType: String?
    /** Expires in. */
    var expiresIn: Double?
    /** Scope. */
    var scope: String?
    /** refresh Token. */
    var refreshToken: String?

    required init?(map: Map) {
    }

    func mapping(map: Map) {
        accessToken <- map["access_token"]
        tokenType <- map["token_type"]
        expiresIn <- map["expires_in"]
        scope <- map["scope"]
        refreshToken <- map["refresh_token"]
    }

    func encode(with aCoder: NSCoder) {

        aCoder.encode(self.accessToken, forKey: "access_token")
        aCoder.encode(self.tokenType, forKey: "token_type")
        aCoder.encode(self.expiresIn, forKey: "expires_in")
        aCoder.encode(self.scope, forKey: "scope")
        aCoder.encode(self.refreshToken, forKey: "refresh_token")

    }

    required init?(coder aDecoder: NSCoder) {

        if let refreshTokenStr = aDecoder.decodeObject(forKey: "refresh_token") as? String {
            self.refreshToken = refreshTokenStr
        }

        if let accessTokenStr = aDecoder.decodeObject(forKey: "access_token") as? String {
            self.accessToken = accessTokenStr
        }

        if let tokenTypeStr = aDecoder.decodeObject(forKey: "token_type") as? String {
            self.tokenType = tokenTypeStr
        }

        if let expiresInDouble = aDecoder.decodeObject(forKey: "expires_in") as? Double {
            self.expiresIn = expiresInDouble
        }

        if let scopeStr = aDecoder.decodeObject(forKey: "scope") as? String {
            self.scope = scopeStr
        }
    }
}
