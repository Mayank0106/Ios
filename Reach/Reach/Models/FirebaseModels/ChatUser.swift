//
//  ChatUser.swift
//
//

import Foundation
import UIKit
import Contacts
import Firebase
import FirebaseAuth
import FirebaseDatabase

enum MessageType {
    case photo
    case video
    case audio
    case text
    case location
}

enum MessageOwner {
    case sender
    case receiver
}

struct ChatUsersPics {
    let image: UIImage
    let userID: String
}

struct ChatUser: Codable {
    // MARK: Properties
    let name: String
    let email: String
    let userId: String
    let userImage: String
    let status: String
    let fcmToken: String
    let isVerified: Bool

    // MARK: Methods

    static func signupWithEmail(email: String, password: String, userName: String, userId: Int, userImage: String = "", completion: @escaping (Bool, String) -> Swift.Void) {

        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if let error = error {
                print("error in signin---\(error)")
                completion(false, error.localizedDescription)
                return
            }
        }

        var values = [String: Any]()
        let fcmToken = AppUtility.getDeviceToken()
        values = ["email": email, "name": userName, "userId": userId, "userImage": userImage, "fcmToken": fcmToken]

        Database.database().reference().child("users").child("\(userId)").updateChildValues(values, withCompletionBlock: { (errr, _) in
            if errr == nil {

                let fcmList = ["fcm_token": AppUtility.getDeviceToken()] as [String: Any]
                let fcmTokenRef = Database.database().reference().child("token/\(userId)")
                fcmTokenRef.updateChildValues(fcmList)
                completion(true, "")
            } else {
                completion(false, "Error in saving Details")
            }
        })
    }

    static func signInWithEmail(email: String, password: String, userName: String, userId: Int, userImage: String = "", completion: @escaping (Bool, String) -> Swift.Void) {

        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if let error = error {
                print("error in signin---\(error)")
                completion(false, error.localizedDescription)
                ChatUser.signupWithEmail(email: email, password: password, userName: userName, userId: userId, userImage: userImage, completion: { (success, message)  in
                    if success {
                        print("true")
                    } else {
                        print("false")
                    }
                })

            } else {
                // MARK: Generate FCM Token List and append FCM Token if it is already created.
                let fcmList = ["fcm_token": AppUtility.getDeviceToken()] as [String: Any]
                let fcmTokenRef = Database.database().reference().child("token/\(userId)")
                fcmTokenRef.updateChildValues(fcmList)
                completion(true, "")
            }
        }
    }

    static func updateUserValues(email: String, userName: String, userId: Int, userImage: String = "", completion: @escaping (Bool, String) -> Swift.Void) {

        var values = [String: Any]()
        let fcmToken = AppUtility.getDeviceToken()
        values = ["email": email, "name": userName, "userId": userId, "userImage": userImage, "fcmToken": fcmToken]

        Database.database().reference().child("users").child("\(userId)").updateChildValues(values, withCompletionBlock: { (errr, _) in
            if errr == nil {

                let fcmList = ["fcm_token": AppUtility.getDeviceToken()] as [String: Any]
                let fcmTokenRef = Database.database().reference().child("token/\(userId)")
                fcmTokenRef.updateChildValues(fcmList)
                completion(true, "")
            } else {
                completion(false, "Error in saving Details")
            }
        })
    }

    static func logOutUser(userId: Int, fcmTokenKey: String, completion: @escaping (Bool) -> Swift.Void) {

        print(fcmTokenKey)
        Database.database().reference().child("token/\(userId)").removeValue()
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
}
