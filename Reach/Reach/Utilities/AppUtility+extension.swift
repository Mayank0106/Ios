//
//  AppUtility+extension.swift
//  OnDemandServiceProvider
//
//  Copyright © 2018 Rajesh. All rights reserved.
//

import Foundation
import UIKit
import Contacts

extension AppUtility {
    // Logout  of application
    static func preloadKeyboard() {
        // Preloads keyboard so there's no lag on initial keyboard appearance.
        let lagFreeField = UITextField()
        AppUtility.getAppDelegate()?.window?.addSubview(lagFreeField)
        lagFreeField.becomeFirstResponder()
        lagFreeField.resignFirstResponder()
        lagFreeField.removeFromSuperview()
    }
    /**
     This method retruns the appropriate message for given error code.
     - parameter code: String
     - returns: String
     */
    static func getErrorMessage(_ code: String) -> String? {
        switch code {
        case "500":
            return "Server error"
        case "401":
            return "Authentication credentials were not provided."
        case "400":
            return "null values are send in non-nullable fields."
        case "1112":
            return "UserAlreadyExist"
        case "1113":
            return "EmailNotRegistered"
        case "1114":
            return "ExpiredOrInvalidOTP"
        case "1115":
            return "NoNotifications"
        case "1116":
            return "ImproperDeviceDetails"
        default:
            return ""
        }
    }
    // Get the random float number
    static func randomFloat(_ min: Double, max: Double) -> Double {
        return min + Double(arc4random_uniform(UInt32(max - min + 1)))
    }
    // MARK: Date time calculation
    static func calculateDateTime(_ dateStr: String) -> Date {
        // Convert string to date object
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = AppConstants.originalDateTimeFormat
        let date = dateFormat.date(from: dateStr)
        return date!
    }
    /**
     This method is used add basic constaraints ie top, bottom, leading and trailing to subView
     - parameter subView:   UIView
     - parameter superView: UIView
     */
    static func addBasicConstraintsOnSubView(_ subView: UIView, onSuperView superView: UIView) {
        subView.translatesAutoresizingMaskIntoConstraints = false
        superView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[subView]|",
                                                                options: NSLayoutFormatOptions.alignmentMask, metrics: nil,
                                                                views: NSDictionary(object: subView, forKey: "subView" as NSCopying) as? [String: AnyObject] ?? [:]))
        superView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[subView]|",
                                                                options: NSLayoutFormatOptions.alignmentMask,
                                                                metrics: nil,
                                                                views: NSDictionary(object: subView,
                                                                                    forKey: "subView" as NSCopying) as? [String: AnyObject] ?? [:]))
    }

    // check that phone number is valid or not
    static func getAllowedCharacterSetForPhoneNr() -> NSMutableCharacterSet {
        let allowedCharacterSet = NSMutableCharacterSet.decimalDigit()
        allowedCharacterSet.invert()
        return allowedCharacterSet
    }
    /**
     This method is used to convert a json string to dictionary
     - parameter text: String
     - returns: [String: AnyObject]
     */
    static func convertStringToDictionary(_ text: String) -> [String: AnyObject]? {
        if let data = text.data(using: String.Encoding.utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject]
            } catch _ as NSError {
            } catch {
                // Catch any other errors
            }
        }
        return nil
    }
    /**
     Update applicationIconBadgeNumber
     - parameter factor: Int (-/+)
     */
    static func updateApplicationIconBadgeNumberBy(_ factor: Int) {
        let badgeNumber = UIApplication.shared.applicationIconBadgeNumber
        if factor < 0 {
            if badgeNumber > 0 {
                UIApplication.shared.applicationIconBadgeNumber = badgeNumber + factor
            }
        } else if badgeNumber > 0 {
            UIApplication.shared.applicationIconBadgeNumber = badgeNumber + factor
        } else {
            UIApplication.shared.applicationIconBadgeNumber = factor
        }
    }
    /**
     Resize the image to new size
     - parameter image:  UIImage
     - parameter toSize: CGSize
     - returns: UIImage
     */
    static func resizeImage(_ image: UIImage, toSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(toSize)
        image.draw(in: CGRect(x: 0, y: 0, width: toSize.width, height: toSize.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage!
    }

    static func setUserDefault(objectToSave: AnyObject?, keyToSave: String) {
        let defaults = UserDefaults.standard
        if objectToSave != nil {
            defaults.set(objectToSave, forKey: keyToSave)
        }
        UserDefaults.standard.synchronize()
    }
    // getUserDefault
    static func getUserDefault(keyToReturnValye: String) -> AnyObject? {
        let defaults = UserDefaults.standard
        if let name = defaults.value(forKey: keyToReturnValye) {
            return name as AnyObject?
        }
        return nil
    }
    // MARK: - Check Email validation
    static func validateEmail(emailStr: String) -> Bool {
        let trimmedString =  trimSpace(str: emailStr)
        let emailRegex: String = "^[_\\p{L}\\p{Mark}0-9-]+(\\.[_\\p{L}\\p{Mark}0-9-]+)*@[\\p{L}\\p{Mark}0-9-]+(\\.[\\p{L}\\p{Mark}0-9]+)*(\\.[\\p{L}\\p{Mark}]{2,})$"
        let predicateForEmail: NSPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return predicateForEmail.evaluate(with: trimmedString)
    }
    // MARK: - trim
    // trim space
    static func trimSpace(str: String) -> String {
        return str.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }

    /**
     Functions to get all the contacts from the Device
     - returns: Phone Contacts
     */
    static func getContacts () -> [String] {

        let toFetch = [CNContactPhoneNumbersKey]
        let request = CNContactFetchRequest(keysToFetch: toFetch as [CNKeyDescriptor])
        var results: [CNContact] = []
        var arrPositionChangeStore: [String] = []
        do {
            let store = CNContactStore()
            try store.enumerateContacts(with: request) {
                contact, _ in
                results.append(contact)
            }
        } catch let err {
            print(err)
        }
        for objResults in results {
            for phoneNumber in objResults.phoneNumbers {

                let number = phoneNumber.value
                arrPositionChangeStore.append(number.stringValue)

            }
        }
        return arrPositionChangeStore
    }
}
