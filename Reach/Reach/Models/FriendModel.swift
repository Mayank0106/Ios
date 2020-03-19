//
// FriendModel.swift
//

import Foundation
import ObjectMapper

enum FriendStatus: String {
    case NotFriends = "ADD"
    case Friends = "FRIENDS"
    case RequestSent = "SENT"
    case RequestRecieved = "ACCEPT"

    var status: Int {
        switch self {
        case .NotFriends:
            return 0
        case .Friends:
            return 1
        case .RequestSent:
            return 2
        case .RequestRecieved:
            return 3
        }
    }

    static func friendStatusInString(value: Int) -> String {

        switch value {
        case 0:
            return FriendStatus.NotFriends.rawValue
        case 1:
            return FriendStatus.Friends.rawValue
        case 2:
            return FriendStatus.RequestSent.rawValue
        default:
            return FriendStatus.RequestRecieved.rawValue

        }
    }

}

struct FriendModel: Mappable {
/// FriendModel properties
    /** Friend ID */
    var id: Int?
    /** Full Name */
    var fullname: String?
    /** Profile Image */
    var profileImage: String?
    /** Username */
    var username: String?
    /** Friend Status **/
    var friendStatus: Int?
    /** is Friend **/
    var isFriend: Bool = true
    /** Is Selected **/
    var isSelected: Bool = false
    /** Is Going **/
    var isGoing: Bool?
    /** Requested Invitations **/
    var arrRequestedInvitations: [FriendModel]?

    /** Is Invited **/
    var isInvited: Bool?

    init() {
    }

    init?(map: Map) {
    }

    mutating func mapping(map: Map) {

        id <- map["id"]
        fullname <- map["fullname"]
        profileImage <- map["profile_image"]
        username <- map["username"]
        friendStatus <- map["friend_status"]
        isFriend <- map["is_friend"]

        isGoing <- map["is_going"]
        arrRequestedInvitations <- map["requested_invtation"]
        isInvited <- map["is_invited"]

    }

    func encodeToJSON() -> [String: Any] {
        return self.toJSON()
    }
}
