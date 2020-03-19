//
//  RequestModel.swift
//  Reach
//
//  Copyright © 2019 Netsolutions. All rights reserved.
//

import Foundation
import ObjectMapper

struct RequestModel: Mappable {

    /** Event ID */
    var id: Int?
    /** Friends ID's*/
    var friendsID: [Int]?
    /** Message to Report **/
    var message: String?
    /** Friend ID**/
    var frndID: Int?
    /** Accept **/
    var accept: Bool?

    init() {
    }

    init?(map: Map) {
    }

    mutating func mapping(map: Map) {
        id <- map["id"]
        friendsID <- map["friends"]
        message <- map["message"]
        frndID <- map["user_id"]
        accept <- map["accept"]

    }

    func encodeToJSON() -> [String: Any] {
        return self.toJSON()
    }
}
