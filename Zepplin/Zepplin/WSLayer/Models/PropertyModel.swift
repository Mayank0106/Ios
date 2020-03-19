//
// PropertyModel.swift
//

import Foundation
import ObjectMapper

struct PropertyModel: Mappable {
/// PropertyModel properties
    /** Id */
    var id: Int?
    /** Photo Count */
    var propertyPhotoCount: Int?
    /** Building tag Name */
    var buildingTagName: String?
    /** Property short description. */
    var propertyShortDescription: String?
    /** View Type Code. */
    var viewTypeCode: String?
    /** billing currency Code. */
    var billingCurrencyCode: String?
    /** Room Rate Amount. */
    var roomRateAmount: Int?
    /** Rating Number. */
    var ratingNumber: String?
    /** Distance */
    var distance: Int?

    init() {
    }

    init?(map: Map) {
    }

    mutating func mapping(map: Map) {
        id <- map["id"]
        propertyPhotoCount <- map["property_photo_count"]
        buildingTagName <- map["building_tag_name"]
        propertyShortDescription <- map["property_short_description"]
        viewTypeCode <- map["view_type_code"]
        billingCurrencyCode <- map["billing_currency_code"]
        roomRateAmount <- map["room_rate_amount"]
        ratingNumber <- map["rating_number"]
        distance <- map["distance"]
    }

    func encodeToJSON() -> [String : Any] {
        return self.toJSON()
    }
}
