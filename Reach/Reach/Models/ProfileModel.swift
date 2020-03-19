//
//  ProfileModel.swift
//  Reach
//
//  Copyright © 2019 Netsolutions. All rights reserved.
//

import Foundation
import ObjectMapper

struct ProfileModel: Mappable {

    /** ID */
    var id: Int?
    /** Full Name */
    var fullname: String?
    /** Username */
    var username: String?
    /** Profile Image */
    var profileImage: String?
    /** Gender */
    var gender: Int?
    /** City */
    var city: ProvinceCityModel?
    /** State Code */
    var state: ProvinceCityModel?
    /** Friend Status */
    var friendStatus: Int?
    /** Party Going Count **/
    var goingCount: Int?

    init() {
    }

    init?(map: Map) {
    }

    mutating func mapping(map: Map) {

        id <- map["id"]
        fullname <- map["fullname"]
        username <- map["username"]
        profileImage <- map["profile_image"]
        gender <- map["gender"]
        city <- map["city"]
        state <- map["state"]
        friendStatus <- map["friend_status"]
        goingCount <- map["party_going_count"]
    }

    func encodeToJSON() -> [String: Any] {
        return self.toJSON()
    }
}
