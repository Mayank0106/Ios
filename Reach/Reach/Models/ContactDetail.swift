//
// ContactDetail.swift
//

import Foundation
import ObjectMapper

struct ContactDict: Mappable {
    var moveStreetObj: [ContactDetail]?   //Array for Contacts
    var isDeleted: Bool?       //Variable to check if we want to delete the contacts from server or not
    init() {
    }
    init?(map: Map) {
    }
    mutating func mapping(map: Map) {
        moveStreetObj <- map["user_contacts"]
        isDeleted <- map["is_deleted"]
    }
    func encodeToJSON() -> [String: Any] {
        return self.toJSON()
    }
}

struct ContactDetail: Mappable {
/// ContactDetail properties
    /** contact type. */
    var contactType: String?
    /** first name of user. */
    var firstname: String?
    /** last name of user. */
    var lastname: String?
    /** mobile number of user. */
    var phone: String?
    /** full name. */
    var fullname: String?
    init() {
    }

    init?(map: Map) {
    }

    mutating func mapping(map: Map) {
        contactType <- map["contact_type"]
        firstname <- map["firstname"]
        lastname <- map["lastname"]
        phone <- map["phone"]
        fullname <- map["fullname"]
    }

    func encodeToJSON() -> [String: Any] {
        return self.toJSON()
    }
}
