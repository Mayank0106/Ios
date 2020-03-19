//
// UserModel.swift
//

import Foundation
import UIKit
import ObjectMapper

class UserModel: NSObject, Mappable, NSCoding {
    /// UserModel properties
    /** User Identifier */
    var id: Int?
    /** Mobile Number */
    var mobileNumber: String?
    /** Access Token */
    var accessToken: String?
    /** Is Active User */
    var isActive: Bool?
    /** Full Name */
    var fullname: String?
    /** Temp Image URL */
    var tempProfileImage: UIImage?
    /** Profile Image URL */
    //var profileImage: Data?
    var profileImage: String?
    /** Gender */
    var gender: Int?
    /** City */
    var city: Int?
    /** State */
    var state: Int?
    /** Snapchat Id */
    var snapchatId: Int?
    /** Is staff */
    var isStaff: Bool?
    /** Is Superuser */
    var isSuperuser: Bool?
    /** Is App User */
    var isAppUser: Bool?
    /** Username */
    var username: String?
    /** Email */
    var email: String?
    /** Last Login */
    var lastLogin: String?
    /** Is notification allowed */
    var isNotificationAllowed: Bool?
    /** Password */
    var password: String?

    /** Device ID */
    var deviceId: String?
    /** Device Token */
    var deviceToken: String?
    /** Device Type */
    var deviceType: Int?

    /** Old Password */
    var oldPassword: String?
    /** New Password */
    var newPassword: String?

    /** State text */
    var stateStr: String?
    /** City text */
    var cityStr: String?

    override init() {
    }

    required init?(map: Map) {
    }

    func mapping(map: Map) {
        id <- map["id"]
        mobileNumber <- map["mobile_number"]
        accessToken <- map["access_token"]
        isActive <- map["is_active"]

        fullname <- map["fullname"]
        tempProfileImage <- map["temp_profile_image"]
        profileImage <- map["profile_image"]
        gender <- map["gender"]
        city <- map["city"]

        state <- map["state"]
        snapchatId <- map["snapchat_id"]
        isStaff <- map["is_staff"]
        isSuperuser <- map["is_superuser"]

        isAppUser <- map["is_app_user"]
        username <- map["username"]
        email <- map["email"]
        lastLogin <- map["last_login"]

        isNotificationAllowed <- map["is_notification_allowed"]
        password <- map["password"]

        deviceId <- map["device_id"]
        deviceToken <- map["device_token"]
        deviceType <- map["device_type"]

        oldPassword <- map["old_password"]
        newPassword <- map["new_password"]

        stateStr <- map["state_text"]
        cityStr <- map["city_text"]
    }

    func encode(with aCoder: NSCoder) {

        aCoder.encode(self.id, forKey: "id")
        aCoder.encode(self.mobileNumber, forKey: "mobile_number")
        aCoder.encode(self.accessToken, forKey: "access_token")
        aCoder.encode(self.isActive, forKey: "is_active")

        aCoder.encode(self.fullname, forKey: "fullname")
        aCoder.encode(self.tempProfileImage, forKey: "temp_profile_image")
        aCoder.encode(self.profileImage, forKey: "profile_image")
        aCoder.encode(self.gender, forKey: "gender")
        aCoder.encode(self.city, forKey: "city")

        aCoder.encode(self.state, forKey: "state")
        aCoder.encode(self.snapchatId, forKey: "snapchat_id")
        aCoder.encode(self.isStaff, forKey: "is_staff")
        aCoder.encode(self.isSuperuser, forKey: "is_superuser")

        aCoder.encode(self.isAppUser, forKey: "is_app_user")
        aCoder.encode(self.username, forKey: "username")
        aCoder.encode(self.email, forKey: "email")
        aCoder.encode(self.lastLogin, forKey: "last_login")

        aCoder.encode(self.isNotificationAllowed, forKey: "is_notification_allowed")
        aCoder.encode(self.password, forKey: "password")
        aCoder.encode(self.deviceId, forKey: "device_id")
        aCoder.encode(self.deviceToken, forKey: "device_token")
        aCoder.encode(self.deviceType, forKey: "device_type")

        aCoder.encode(self.stateStr, forKey: "state_text")
        aCoder.encode(self.cityStr, forKey: "city_text")
    }

    required init?(coder aDecoder: NSCoder) {

        if let identifier = aDecoder.decodeObject(forKey: "id") as? Int {
            self.id = identifier
        }

        if let mobNo = aDecoder.decodeObject(forKey: "mobile_number") as? String {
            self.mobileNumber = mobNo
        }

        if let accessToken = aDecoder.decodeObject(forKey: "access_token") as? String {
            self.accessToken = accessToken
        }

        if let isActive = aDecoder.decodeObject(forKey: "is_active") as? Bool {
            self.isActive = isActive
        }

        if let fullName = aDecoder.decodeObject(forKey: "fullname") as? String {
            self.fullname = fullName
        }

        if let tempProfileImage = aDecoder.decodeObject(forKey: "temp_profile_image") as? UIImage {
            self.tempProfileImage = tempProfileImage
        }

        if let profileImage = aDecoder.decodeObject(forKey: "profile_image") as? String {
            self.profileImage = profileImage
        }

        if let gender = aDecoder.decodeObject(forKey: "gender") as? Int {
            self.gender = gender
        }

        if let city = aDecoder.decodeObject(forKey: "city") as? Int {
            self.city = city
        }

        if let state = aDecoder.decodeObject( forKey: "state") as? Int {
            self.state = state
        }

        if let snapChatID = aDecoder.decodeObject(forKey: "snapchat_id") as? Int {
            self.snapchatId = snapChatID
        }

        if let isStaff = aDecoder.decodeObject(forKey: "is_staff") as? Bool {
            self.isStaff = isStaff
        }

        if let isSuperUser = aDecoder.decodeObject(forKey: "is_superuser") as? Bool {
            self.isSuperuser = isSuperUser
        }

        if let isAppUser = aDecoder.decodeObject(forKey: "is_app_user") as? Bool {
            self.isAppUser = isAppUser
        }

        if let username = aDecoder.decodeObject(forKey: "username") as? String {
            self.username = username
        }

        if let email = aDecoder.decodeObject(forKey: "email") as? String {
            self.email = email
        }

        if let lastLogin = aDecoder.decodeObject(forKey: "last_login") as? String {
            self.lastLogin = lastLogin
        }

        if let isNotificationAllowed = aDecoder.decodeObject(forKey: "is_notification_allowed") as? Bool {
            self.isNotificationAllowed = isNotificationAllowed
        }

        if let password = aDecoder.decodeObject(forKey: "password") as? String {
            self.password = password
        }

        if let deviceID = aDecoder.decodeObject(forKey: "device_id") as? String {
            self.deviceId = deviceID
        }

        if let deviceToken = aDecoder.decodeObject(forKey: "device_token") as? String {
            self.deviceToken = deviceToken
        }

        if let deviceType = aDecoder.decodeObject(forKey: "device_type") as? Int {
            self.deviceType = deviceType
        }

        if let stateStr = aDecoder.decodeObject(forKey: "state_text") as? String {
            self.stateStr = stateStr
        }

        if let cityStr = aDecoder.decodeObject(forKey: "city_text") as? String {
            self.cityStr = cityStr
        }
    }

    func encodeToJSON() -> [String: Any] {
        return self.toJSON()
    }
}
