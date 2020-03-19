//
// ProvinceCityModel.swift
//

import Foundation
import ObjectMapper

struct ProvinceCityModel: Mappable {
/// ProvinceCityModel properties
    /** Province/City ID */
    var id: Int?
    /** Name */
    var name: String?
    /** State Code */
    var stateCode: String?

    init() {
    }

    init?(map: Map) {
    }

    mutating func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        stateCode <- map["state_code"]
    }

    func encodeToJSON() -> [String: Any] {
        return self.toJSON()
    }
}
