//
// User.swift
//

import Foundation
import ObjectMapper

struct User: Mappable {
/// User properties
    /** Id of user. */
    var id: Int?
    /** user email id. */
    var userEmailId: String?
    /** Email of user. */
    var corporateIndicator: Bool?
    /** Password of user. */
    var password: String?
    /** date from user exist. */
    var userSinceDate: String?
    /** last login date */
    var lastLogin: String?
    /** Name of user. */
    var firstName: String?
    /** middle name of user. */
    var middleName: String?
    /** Birth date of user. */
    var birthDate: String?
    /** last name of user. */
    var lastName: String?
    /** company name of user. */
    var companyName: String?
    /** address line_1_text of user. */
    var addressLine1Text: String?
    /** address line_2_text of user. */
    var addressLine2Text: String?
    /** address line_3_text of user */
    var addressLine3Text: String?
    /** address city_name of user */
    var addressCityName: String?
    /** address regional_area_code user */
    var addressRegionalAreaCode: String?
    /** address postal_code of user */
    var addressPostalCode: String?
    /** address country_code of user */
    var addressCountryCode: String?
    /** address country_name of user */
    var addressCountryName: String?
    /** mobile phone_number of user */
    var mobilePhoneNumber: String?
    /** mobile phone_number of user */
    var mainPhoneNumber: String?
    /** personal photo_path_text of user */
    var personalPhotoPathText: String?
    /** token */
    var accessToken: String?

    init() {
    }

    init?(map: Map) {
    }

    mutating func mapping(map: Map) {
        id <- map["id"]
        userEmailId <- map["user_email_id"]
        corporateIndicator <- map["corporate_indicator"]
        password <- map["password"]
        userSinceDate <- map["user_since_date"]
        lastLogin <- map["last_login"]
        firstName <- map["first_name"]
        middleName <- map["middle_name"]
        birthDate <- map["birth_date"]
        lastName <- map["last_name"]
        companyName <- map["company_name"]
        addressLine1Text <- map["address_line_1_text"]
        addressLine2Text <- map["address_line_2_text"]
        addressLine3Text <- map["address_line_3_text"]
        addressCityName <- map["address_city_name"]
        addressRegionalAreaCode <- map["address_regional_area_code"]
        addressPostalCode <- map["address_postal_code"]
        addressCountryCode <- map["address_country_code"]
        addressCountryName <- map["address_country_name"]
        mobilePhoneNumber <- map["mobile_phone_number"]
        mainPhoneNumber <- map["main_phone_number"]
        personalPhotoPathText <- map["personal_photo_path_text"]
        accessToken <- map["access_token"]
    }

    func encodeToJSON() -> [String : Any] {
        return self.toJSON()
    }
}
