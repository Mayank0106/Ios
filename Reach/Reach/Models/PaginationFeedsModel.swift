//
// PaginationFeedsModel.swift
//

import Foundation
import ObjectMapper

struct PaginationFeedsModel: Mappable {
/// PaginationFeedsModel properties
    /** Next */
    var next: String?
    /** Previous */
    var previous: String?
    /** Feeds */
    var results: [MyEventModel]?

    init() {
    }

    init?(map: Map) {
    }

    mutating func mapping(map: Map) {
        next <- map["next"]
        previous <- map["previous"]
        results <- map["results"]
    }

    func encodeToJSON() -> [String: Any] {
        return self.toJSON()
    }
}
