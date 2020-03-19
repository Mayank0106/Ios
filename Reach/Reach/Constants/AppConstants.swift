//
//  Constants.swift

import Foundation
import UIKit

struct AppConstants {
    // check is app Install or not
    static let isAppUninstallKey = "isAppUninstall"

    // Key chain to store values
    static let userDeviceTokenKeyChain = "userDeviceToken"
    static let appTokenKeyChain =  "appTokenKey"
    static let userModelKeyChain = "userModelKey"
    // error key
    static let errorDescription =  "error_description"
    // error
    static let error =  "error"
    static let errorDetail = "detail"
    // status key
    static let statusKey = "status"
    // success Service value
    static let successServiceCode = 200
    // tokenExpired Service value
    static let tokenExpired = 401
    // access denied value
    static let accessDenied = 422
    // other value
    static let otherSuccess = 111
    
    // Check No Version update
    static let noVersionAvailable = 111

    // s3 bucket
    static let addthumbImage = "_thumb."
    // for profile image size
    static let profilePicThumbSize: CGFloat = 126
    static let profilePicLargeSize: CGFloat = 480

    static let mobileNoLength = 10
    static let countryCode = "1"
    static let plusText = "+"
    static let whiteSpace = " "

    // Time
    static let localIdentifier = "en_US_POSIX"
    static let dateFormatDisplay = "dd-MMMM-yyyy"
    static let dateFormatServer = "yyyy-MM-dd"
    static let fullDateFormatSessionsDisplay = "MMM-dd-yyyy"
    static let timeZoneAbbreviation = "IST"

    // date time
    static let timeFormatSessionsServer = "yyyy-MM-dd HH:mm:ss"
    static let dateFormatSessionsDisplay = "MMMM-dd"
    static let fullDateFormatVideoDisplay = "MMMM-dd-yyyy"
    static let timeFormatSessionDisplay = "hh:mm a"
    static let originalDateTimeFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    static let eventDateTimeFormat = "yyyy-MM-dd'T'HH:mm:ssZ"

    static let maxFullNameLength = 30
    static let maxUsernameLength = 30
    static let maxPasswordLength = 15
    static let maxEmailLength = 50
    static let minimumUsernameLength = 0

    static let chatSenderBubblecolor = UIColor(red: 239.0 / 255.0, green: 239.0 / 255.0, blue: 239.0 / 255.0, alpha: 1.0)
    static let chatReceipientBubbleColor = UIColor(red: 79.0 / 255.0, green: 98.0 / 255.0, blue: 215.0 / 255.0, alpha: 1.0)
    static let ConversationId = "ConversationId"
    static let chatPagingLimit: UInt = 30
    static var currentUser: ChatUser?
    static var lastChatItem: ChatMessage?
    static var currentConversationId: String?

    static let fcmTokenKey = "AAAAPjNUCQM:APA91bFxcAPv1lnT-on07_yWITCNOoNED_CNDKQvhPLSY76YNdILipp1CyGRYIzuY-OBQ4DxfFmW6noQhl642TRugVyES7A-yGoPDmj7dlIutHQ1ulC0qNWDtjT3ewnFBSBzszbiV9u1"

    static let NexmoAPIURL = "https://api.nexmo.com/verify/check/json"
}

let appStoryboard: UIStoryboard =  UIStoryboard(name: "Main", bundle: Bundle.main)

let tabBarStoryboard = UIStoryboard(name: "Tabbar", bundle: Bundle.main)

let appDelegate = (UIApplication.shared.delegate as? AppDelegate)!

let defaults = UserDefaults.standard

let windowFrame = appDelegate.window!.frame.size

let tabBarHt: CGFloat = 69
