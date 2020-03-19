//
// PaginationModel.swift
//

import Foundation
import ObjectMapper

struct PaginationModel: Mappable {
/// PaginationModel properties
    /** Next */
    var next: String?
    /** Previous */
    var previous: String?
    /** Total number of people **/
    var totalNumber: Int?
    /** Results */
    var results: [FriendModel]?

    init() {
    }

    init?(map: Map) {
    }

    mutating func mapping(map: Map) {
        next <- map["next"]
        previous <- map["previous"]
        totalNumber <- map["total_count"]
        results <- map["results"]
    }

    func encodeToJSON() -> [String: Any] {
        return self.toJSON()
    }
}
