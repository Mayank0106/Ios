//
// MyEventModel.swift
//

import Foundation
import ObjectMapper

struct MyEventModel: Mappable {
/// MyEventModel properties
    /** Event ID */
    var id: Int?
    /** Event Name */
    var name: String?
    /** Event Type */
    var eventType: Int?
    /** Banner Image */
    var bannerImage: String?
    /** Description */
    var description: String?
    /** Start Time */
    var startTime: String?
    /** Address Time */
    var addressTime: Int?
    /** Address */
    var address: String?
    /** Street 1 Address */
    var street1Address: String?
    /** Street 2 Address */
    var street2Address: String?
    /** Recipients */
    var arrRecipients: [FriendModel]?
    /** Host */
    var host: FriendModel?
    /** Is Going/Not */
    var isGoing: Bool?
    /** Is Going Count */
    var goingCount: Int?
    /** People Going */
    var peopleGoing: [FriendModel]?
    /** Person List Count **/
    var personListCount: Int?
    /** Invitation Count **/
    var invitationCount: Int?
    /** Male Invitation Count **/
    var maleInvitationCount: Int?
    /** Female Invitation Count **/
    var femaleInvitationCount: Int?
    /** Invitation List */
    var invitationList: [FriendModel]?
    /** Draft **/
    var draft: Bool?

    init() {
    }

    init?(map: Map) {
    }

    mutating func mapping(map: Map) {

        id <- map["id"]
        name <- map["name"]
        eventType <- map["event_type"]
        bannerImage <- map["banner_image"]
        description <- map["description"]
        startTime <- map["start_time"]

        addressTime <- map["address_time"]
        address <- map["address"]
        street1Address <- map["street1"]
        street2Address <- map["street2"]

        arrRecipients <- map["recipients"]
        host <- map["host"]
        isGoing <- map["is_going"]
        goingCount <- map["going_count"]
        peopleGoing <- map["people_going"]

        personListCount <- map["person_list_count"]

        invitationCount <- map["invitation_count"]
        maleInvitationCount <- map["male_invitation_count"]
        femaleInvitationCount <- map["female_invitation_count"]

        invitationList <- map["invitation_list"]
        draft <- map["is_draft"]
    }

    func encodeToJSON() -> [String: Any] {
        return self.toJSON()
    }
}
