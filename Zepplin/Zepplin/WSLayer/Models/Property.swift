//
// Property.swift
//

import Foundation
import ObjectMapper

struct Property: Mappable {
/// Property properties
    /** Latitude */
    var latitude: Int?
    /** Longitude */
    var longitude: String?
    /** Start Date */
    var startDate: String?
    /** End date */
    var endDate: String?

    init() {
    }

    init?(map: Map) {
    }

    mutating func mapping(map: Map) {
        latitude <- map["latitude"]
        longitude <- map["longitude"]
        startDate <- map["start_date"]
        endDate <- map["end_date"]
    }

    func encodeToJSON() -> [String : Any] {
        return self.toJSON()
    }
}
