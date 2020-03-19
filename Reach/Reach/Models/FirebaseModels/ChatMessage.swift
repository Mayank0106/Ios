//
//  ChatMessage.swift
//
//

import Foundation
import UIKit
import Firebase
import Alamofire
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class ChatMessage {

    // MARK: Properties
    var owner: MessageOwner
    var type: MessageType
    var content: Any
    var timestamp: Int = 0
    var isRead: Bool
    var image: UIImage?
    var messageKey: String?
    var msgLocation: String?
    var toID: String?
    var fromID: String?
    var userName: String?
    var userImage: String?

   // MARK: Methods
    class func downloadAllMessages(convId: String, recieverId: String, completion: @escaping (ChatMessage) -> Swift.Void) {

        let ref = Database.database().reference().child("Conversation").child(convId).queryLimited(toLast: UInt(AppConstants.chatPagingLimit))
        ref.observe(.childAdded, with: { (snap) in
            if snap.exists() {
                let receivedMessage = snap.value as? [String: Any]
                let keyMessage = snap.key

                let type = MessageType.text
                let content = receivedMessage?["content"] as? String
                let fromID = receivedMessage?["fromID"] as? String
                guard let fromUserID = fromID else { return }
                var userName = ""
                var userImage = ""

                Database.database().reference().child("users").child("\(fromUserID)").observe(.value, with: { (snapshot) in
                    if snapshot.exists() {
                        if let snapDict = snapshot.value as? [String: AnyObject] {
                            userName = snapDict["name"] as? String ?? ""
                            userImage = snapDict["userImage"] as? String ?? ""

                            var timestamp = Int(Date().timeIntervalSince1970)
                            if let times = receivedMessage?["timestamp"] as? Int {
                                timestamp = times
                                print(timestamp)
                            }
                            if fromID == recieverId {
                                let message = ChatMessage.init(type: type, content: content ?? "", owner: .sender, timestamp: timestamp, isRead: true, messageKey: keyMessage, msgLocation: convId, fromID: fromID ?? "", toID: "", userName: userName, userImage: userImage)
                                completion(message)
                            } else {
                                let message = ChatMessage.init(type: type, content: content ?? "", owner: .receiver, timestamp: timestamp, isRead: true, messageKey: keyMessage, msgLocation: convId, fromID: fromID ?? "", toID: "", userName: userName, userImage: userImage)
                                completion(message)
                            }
                        }
                    }
                })

            }
        })
    }

    class func downloadPaginatedData(lastValue: Any, forConvID: String, completion: @escaping (ChatMessage) -> Swift.Void) {
        if let currentUserID = Auth.auth().currentUser?.uid {
            let ref = Database.database().reference().child("conversations").child(forConvID)
            ref.queryOrderedByKey().queryEnding(atValue: lastValue).queryLimited(toLast: UInt(AppConstants.chatPagingLimit)).observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
                if snapshot.exists() {

                    for (indx, item) in snapshot.children.reversed().enumerated() {
                        let receivedMessage = (item as! DataSnapshot).value as! [String: Any]
                        let keyMessage = (item as! DataSnapshot).key
                        if let messageType = receivedMessage["type"] as? String {
                            var type = MessageType.text
                            switch messageType {
                            case "photo":
                                type = .photo
                            case "location":
                                type = .location
                            case "audio":
                                type = .audio
                            case "video":
                                type = .video
                            default: break
                            }
                            let content = receivedMessage["content"] as! String
                            let fromID = receivedMessage["fromID"] as! String
                            var timestamp = Int(Date().timeIntervalSince1970)
                            if let times = receivedMessage["timestamp"] as? Int {
                                timestamp = times
                            }
                            if indx != 0 {
                                if fromID == currentUserID {
                                    let message = ChatMessage.init(type: type, content: content, owner: .receiver, timestamp: timestamp, isRead: true, messageKey: keyMessage, msgLocation: "", fromID: fromID, toID: "")
                                    completion(message)
                                } else {
                                    let message = ChatMessage.init(type: type, content: content, owner: .sender, timestamp: timestamp, isRead: true, messageKey: keyMessage, msgLocation: "", fromID: fromID, toID: "")
                                    completion(message)
                                }
                            }
                        }
                    }
                }
            })
        }
    }

    class func markMessagesRead(convId: String) {
        if let currentUserID = Auth.auth().currentUser?.uid {
            Database.database().reference().child("Conversation").child(convId).observeSingleEvent(of: .value, with: { (snap) in
                if snap.exists() {
                    for item in snap.children {
                        let receivedMessage = (item as! DataSnapshot).value as! [String: Any]
                        let fromID = receivedMessage["fromID"] as! String
                        if fromID != currentUserID {
                            Database.database().reference().child("Conversation").child(convId).child((item as! DataSnapshot).key).child("isRead").setValue(true)
                        }
                    }
                }
            })
        }
    }

    class func unReadMessagesCount(forConvID: String, completion: @escaping (Int) -> Swift.Void) {
        var count: Int = 0
        if let currentUserID = Auth.auth().currentUser?.uid {
            Database.database().reference().child("conversations").child(forConvID).observeSingleEvent(of: .value, with: { (snap) in
                if snap.exists() {
                    for item in snap.children {
                        let receivedMessage = (item as! DataSnapshot).value as! [String: Any]
                        let fromID = receivedMessage["fromID"] as! String
                        if fromID != currentUserID {
                            Database.database().reference().child("conversations").child(forConvID).child((item as! DataSnapshot).key).child("isRead").queryOrderedByValue().queryEqual(toValue: false).observe(.value) { (data: DataSnapshot) in
                                count = count + 1
                            }
                        }
                    }
                    completion(count)
                }
            })
        }
    }

    func downloadLastMessage(forLocation: String, completion: @escaping () -> Swift.Void) {

        if let currentUserID = Auth.auth().currentUser?.uid {
            let que = Database.database().reference().child("conversations").child(forLocation)
            que.queryOrderedByKey().queryLimited(toLast: 1).observe(.value, with: { (snapshot) in
                if snapshot.exists() {

                    for snap in snapshot.children {
                        let receivedMessage = (snap as! DataSnapshot).value as! [String: Any]

                        self.timestamp = 0
                        if let time = receivedMessage["timestamp"] as? Int {
                            self.timestamp = time
                        }

                        var messageType = ""
                        if let message = receivedMessage["type"] as? String {
                            messageType = message
                        }

                        var fromID = ""
                        if let from = receivedMessage["fromID"] as? String {
                            fromID = from
                        }

                        self.self.isRead = false
                        if let read = receivedMessage["isRead"] as? Bool {
                            self.isRead = read
                        }
                        var type = MessageType.text

                        switch messageType {
                        case "text":
                            type = .text
                            self.content = receivedMessage["content"] ?? ""
                        case "photo":
                            type = .photo
                            self.content = "Image"
                        case "location":
                            type = .location
                            self.content = "Location"
                        case "video":
                            type = .video
                            self.content = "Video"
                        case "audio":
                            type = .audio
                            self.content = "Audio"
                        default: break
                        }
                        self.type = type
                        if currentUserID == fromID {
                            self.owner = .receiver
                        } else {
                            self.owner = .sender
                        }
                        completion()
                    }
                }
            })
        }
    }

    class func send(message: ChatMessage, eventId: String?, userID: String?,
                    convId: String?, completion: @escaping (Bool, String) -> Swift.Void) {

        let values = ["type": "text", "content": message.content, "fromID": userID ?? "0", "toID": convId ?? "0", "timestamp": message.timestamp, "isRead": false]

        ChatMessage.saveMessage(withValues: values, eventId: eventId, convId: convId, completion: { (status, convId) in

            completion(status, convId)
        })
    }

    // MARK: Save Message to Database
    class func saveMessage(withValues: [String: Any], eventId: String?, convId: String?, completion: @escaping (Bool, String) -> Swift.Void) {

        if let convId = convId {
            Database.database().reference().child("Conversation").child("\(String(describing: convId))")
                .childByAutoId().setValue(withValues, withCompletionBlock: { (error, _) in
                if error == nil {
                    completion(true, convId)
                } else {
                    print("Error---\(error.debugDescription)")
                    completion(false, convId)
                }
            })
        } else {
            let convId = UUID().uuidString
            let conversationId = [AppConstants.ConversationId: convId]
            Database.database().reference().child("Events").child("\(String(describing: eventId!))")
                .setValue(conversationId, withCompletionBlock: { (error, _) in
                if error == nil {
                    Database.database().reference().child("Conversation").child("\(convId)")
                        .childByAutoId().setValue(withValues, withCompletionBlock: { (error, _) in
                        if error == nil {
                            completion(true, convId)
                        } else {
                            print("Error---\(error.debugDescription)")
                            completion(false, convId)
                        }
                    })
                    completion(true, convId)
                } else {
                    print("Error---\(error.debugDescription)")
                    completion(false, convId)
                }
            })
        }
    }

    // MARK: Inits
    init(type: MessageType, content: Any, owner: MessageOwner,
         timestamp: Int, isRead: Bool, messageKey: String, msgLocation: String,
         fromID: String, toID: String, userName: String = "", userImage: String = "") {

        self.type = type
        self.content = content
        self.owner = owner
        self.timestamp = timestamp
        self.isRead = isRead
        self.messageKey = messageKey
        self.msgLocation = msgLocation
        self.fromID = fromID
        self.toID = toID
        self.userName = userName
        self.userImage = userImage
    }

    class func sendChatNotification(body: String,
                                    recepientId: String,
                                    groupName: String,
                                    eventID: Int) {

        guard let data = KeychainWrapper.standard.object(forKey: AppConstants.userModelKeyChain),
            let userObj = data as? UserModel, let userName = userObj.username else { return }

        let params = ["notification": ["body": userName + " @ " + groupName.lowercased() + "\n" + body, "sound": "default"],
                      "data": ["body": ["event_id": eventID], "title": body],
                      "priority": "high",
                      "to": recepientId] as [String: Any]

        let headers = ["Content-Type": "application/json", "Authorization": "key=\(AppConstants.fcmTokenKey)"]
        Alamofire.request(URL(string: "https://fcm.googleapis.com/fcm/send")!,
                          method: .post, parameters: params,
                          encoding: JSONEncoding.default,
                          headers: headers)
            .responseJSON { response in
                print(response.request as Any)  // original URL request
                print(response.response as Any) // URL response
                print(response.result.value as Any)   // result of response serialization
        }
    }
}
