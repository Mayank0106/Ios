//
// PropertyList.swift
//

import Foundation
import ObjectMapper

struct PropertyList: Mappable {
/// PropertyList properties
    /** Next */
    var next: String?
    /** Previous */
    var previous: String?
    var result: [PropertyModel]?

    init() {
    }

    init?(map: Map) {
    }

    mutating func mapping(map: Map) {
        next <- map["next"]
        previous <- map["previous"]
        result <- map["result"]
    }

    func encodeToJSON() -> [String : Any] {
        return self.toJSON()
    }
}
