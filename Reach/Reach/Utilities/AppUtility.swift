// AppUtility.swift

import Foundation
import UIKit
import AVFoundation
import CoreTelephony
import IQKeyboardManagerSwift
import Alamofire
import AWSS3

struct AppUtility {
    static let keyDeviceId = "DeviceIdentifier"
    // allow - ( ) and space
    static let AcceptableSpecialChars = "-()+"
    static let AcceptableDigitsChars = "0123456789"
    enum ObjectType: Int { case NumberType = 0, StringType = 1 }
    /**
     Get the reference of AppDelegate
     - returns: AppDelegate
     */
    static func getAppDelegate () -> AppDelegate? {
        if let appDelegateValue = UIApplication.shared.delegate as? AppDelegate {
            return appDelegateValue
        } else {
            return nil
        }
    }
    /**
     Get the width of screen
     - returns: AppDelegate
     */
    static func getScreenWidth () -> CGFloat? {
        let screenSize = UIScreen.main.bounds
        return screenSize.size.width
    }
    /**
     Get the height of screen
     - returns: AppDelegate
     */
    static func getScreenHeight () -> CGFloat? {
        let screenSize = UIScreen.main.bounds
        return screenSize.size.height
    }
    // MARK: - Get value from dictionary
    static func getObjectForKey(_ key: String!, dictResponse: NSDictionary!) -> AnyObject! {
        if key != nil {
            if let dict = dictResponse {
                if let value: AnyObject = dict.value(forKey: key) as AnyObject? {
                    return value
                } else {
                    return nil
                }
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    // MARK: - Show AlertView
    static func showAlert(_ title: String, message: String, delegate: AnyObject?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK".localized, style: .cancel)
        alertController.addAction(okAction)
        AppUtility.getAppDelegate()?.window?.rootViewController?.present(alertController,
                                                                         animated: true)
    }
    static func showAlertInViewController(_ title: String, message: String, viewController: UIViewController) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK".localized, style: .cancel)
        alertController.addAction(okAction)
        viewController.present(alertController, animated: true)
    }
    // MARK: - Get value from user defaults
    static func getValueFromUserDefaultsForKey(_ keyName: String!) -> AnyObject? {
        if keyName.isBlank {
            return nil
        }
        if let value: AnyObject? = UserDefaults.standard.object(forKey: keyName) as AnyObject?? {
            return value
        }
        return nil
    }
    // MARK: - Set value to user defaults
    static func setValueToUserDefaultsForKey(_ keyName: String!, value: AnyObject!) {
        if keyName.isBlank {
            return
        }
        if value == nil {
            return
        }
        UserDefaults.standard.setValue(value, forKey: keyName)
        UserDefaults.standard.synchronize()
    }
    // MARK: - remove value from user defaults
    static func removeValueFromUserDefaultsForKey(_ keyName: String!) {
        if keyName.isBlank {
            return
        }
        UserDefaults.standard.removeObject(forKey: keyName)
        UserDefaults.standard.synchronize()
    }

    // Used to fetch the controller via StoryBoard
    static func fetchViewControllerWithName(_ vcName: String, storyBoardName: String) -> UIViewController {
        let storyboard = UIStoryboard(name: storyBoardName, bundle: nil)
        let controller: UIViewController = storyboard.instantiateViewController(withIdentifier: vcName)
        return controller
    }

    static func classWithString(_ str: String) -> AnyClass {
        return NSClassFromString(str)!
    }
    // MARK : Navigation bar helper methods
    static func changeNavBarAppearance() {
        // Change the color of the navigation and status bar
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        navigationBarAppearace.barTintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 20), NSAttributedStringKey.foregroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)]
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
    }
    // is ipad
    static func getIsIpadDeviceType() -> Bool {
        // 1. request an UITraitCollection instance
        let deviceIdiom = UIScreen.main.traitCollection.userInterfaceIdiom
        // 2. check the idiom
        switch deviceIdiom {
        case .pad:
            return true
        default:
            return false
        }
    }
    /// Set IQKeyboard manager
    static func setIQKeyBoardManager() {
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        IQKeyboardManager.shared.enableAutoToolbar = true
    }
    /**
     Check if network supports
     - returns: Bool
     */
    static func isNetworkAvailable() -> Bool {
        let net = NetworkReachabilityManager()
        if let isReachable = net?.isReachable {
            return isReachable
        }
        return false
    }

    /// Create Device Info Object
    ///
    /// - Returns: Device Info Object
    static func createDeviceInfoObject() -> DeviceInfo {

        var deviceInfo = DeviceInfo()

        let strDeviceID = UIDevice.current.identifierForVendor?.uuidString
        deviceInfo.deviceId = strDeviceID
        deviceInfo.deviceType = 2 // for iPhone
        if let deviceToken = KeychainWrapper.standard.string(forKey: AppConstants.userDeviceTokenKeyChain) {
            deviceInfo.deviceToken = deviceToken
        }
        deviceInfo.deviceOS = UIDevice.current.systemVersion
        return deviceInfo
    }

    /// Is Email Valid
    ///
    /// - Parameter testStr: string for email
    /// - Returns: True/false
    static func isValidEmail(testStr: String) -> Bool {

        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"

        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }

    /// Is Password valid
    ///
    /// - Parameter password: password
    /// - Returns: True/False
    static func isValidPassword(password: String?) -> Bool {
        guard password != nil else {
            return false
        }
        //        let passwordRegex: String = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d@$!%*#?&]{6,}$"
        let passwordRegex: String = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d@$!%*#?&]{6,15}$"
        let predicateForPswd: NSPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
//        return predicateForPswd.evaluate(with: passwordStr)
//
//        let passwordPred = NSPredicate(format: "SELF MATCHES %@”, “^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d@$!%*#?&]{6,}$")
//        //let passwordPred = NSPredicate(format: "SELF MATCHES %@", "^(?=.*?[#?!@$%^&*-]).{6,15}$")
//        //“^(?=.*[!@#$&*])[A-Za-z0-9]{6,15}$"
        return predicateForPswd.evaluate(with: password)
    }

    /// Get All allowed character set with alphanumeric, . , _ , -.
    ///
    /// - Returns: All allowed character set
    static func getAllowedCharacterSet() -> NSMutableCharacterSet {
        let allowedCharacterSet = NSMutableCharacterSet.alphanumeric()
        allowedCharacterSet.addCharacters(in: "._-")
        allowedCharacterSet.invert()
        return allowedCharacterSet
    }

    /// Forammting mobile no with country code
    ///
    /// - Parameter text: Mobiel No
    /// - Returns: Foramatted Mobile No
    static func foramtingTheMobile(_ text: String) -> String {

        var tempText = text
        if tempText.length == 10 {
            tempText.insert("(", at: tempText.startIndex)
            tempText.insert(")", at: tempText.index(tempText.startIndex, offsetBy: 4))
            tempText.insert(" ", at: tempText.index(tempText.startIndex, offsetBy: 5))
            tempText.insert("-", at: tempText.index(tempText.startIndex, offsetBy: 9))
        }
        return  "+\(AppConstants.countryCode) \(tempText)"
    }

    /// Set S3 Bucket
    static func setS3Bucket() {
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: AWSRegionType.CACentral1, identityPoolId: Configuration.s3PoolId())
        let configuration = AWSServiceConfiguration(region: .CACentral1, credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
    }

    /// Set Nav Bar Apperance
    static func setNavBarAppearance() {

        UINavigationBar.appearance().tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        UINavigationBar.appearance().backgroundColor = #colorLiteral(red: 0.168627451, green: 0.168627451, blue: 0.168627451, alpha: 1)

    }

    /// Set Text field Appearance
    static func setTextFieldCursor() {
        UITextField.appearance().tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)

    }
    
    // MARK: Remove keyChain
    static func removeKeyChainValues() {
        if AppUtility.getValueFromUserDefaultsForKey(AppConstants.isAppUninstallKey) == nil {
            KeychainWrapper.standard.removeObject(forKey: AppConstants.userDeviceTokenKeyChain)
            self.removeKeyChain(isAppTokenRemove: true)
            AppUtility.setValueToUserDefaultsForKey(AppConstants.isAppUninstallKey, value: true as AnyObject)
        }
    }
    static func removeKeyChain(isAppTokenRemove: Bool = false) {
        if isAppTokenRemove { KeychainWrapper.standard.removeObject(forKey: AppConstants.appTokenKeyChain)}
        KeychainWrapper.standard.removeObject(forKey: AppConstants.userModelKeyChain)
    }

    static func setAttributedString(strValue: String, typeToShow: String, strValue1: String, typeToShow1: String) -> NSMutableAttributedString? {

        let combination = NSMutableAttributedString()
        combination.append(NSAttributedString(string: strValue))
        combination.addAttributes([NSAttributedStringKey.font: UIFont(name: "Helvetica Bold", size: 11.0)!, NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0.7803921569, green: 0.7803921569, blue: 0.7803921569, alpha: 1)], range: NSRange(location: 0, length: strValue.length))

        let strType = NSMutableAttributedString(string: typeToShow)
        strType.addAttributes([NSAttributedStringKey.font: UIFont(name: "Helvetica Bold", size: 11.0)!, NSAttributedStringKey.foregroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)], range: NSRange(location: 0, length: strType.length))
        combination.append(strType)

        let strAnd = NSMutableAttributedString(string: strValue1)
        strAnd.addAttributes([NSAttributedStringKey.font: UIFont(name: "Helvetica Bold", size: 11.0)!, NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0.7803921569, green: 0.7803921569, blue: 0.7803921569, alpha: 1)], range: NSRange(location: 0, length: strAnd.length))
        combination.append(strAnd)

        let strPolicy = NSMutableAttributedString(string: typeToShow1)
        strPolicy.addAttributes([NSAttributedStringKey.font: UIFont(name: "Helvetica Bold", size: 11.0)!, NSAttributedStringKey.foregroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)], range: NSRange(location: 0, length: strPolicy.length))
        combination.append(strPolicy)

        return combination
    }

    static func setAttributedStringForTabCreateParty(create: String, party: String) -> NSMutableAttributedString? {

        let combination = NSMutableAttributedString()
        combination.append(NSAttributedString(string: create))
        combination.addAttributes([NSAttributedStringKey.font: UIFont(name: "Helvetica Bold", size: 12.0)!, NSAttributedStringKey.foregroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)], range: NSRange(location: 0, length: create.length))

        let strType = NSMutableAttributedString(string: party)
        strType.addAttributes([NSAttributedStringKey.font: UIFont(name: "Helvetica Bold", size: 15.0)!, NSAttributedStringKey.foregroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)], range: NSRange(location: 0, length: party.length))
        combination.append(strType)

        return combination

    }

    static func setAttributedStringForEventDetail(girls: String, boys: String, isFromInvitationList: Bool = false) -> NSMutableAttributedString? {

        let combination = NSMutableAttributedString()
        combination.append(NSAttributedString(string: girls))
        combination.addAttributes([NSAttributedStringKey.font: UIFont(name: "Helvetica Bold", size: 11.0)!, NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0.9019607843, green: 0.1960784314, blue: 0.1960784314, alpha: 1)], range: NSRange(location: 0, length: girls.length))

        let slash = NSMutableAttributedString(string: " / ")
        if isFromInvitationList {
            slash.addAttributes([NSAttributedStringKey.font: UIFont(name: "Helvetica Bold", size: 11.0)!, NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0.9019607843, green: 0.1960784314, blue: 0.1960784314, alpha: 1)], range: NSRange(location: 0, length: slash.length))
        } else {
            slash.addAttributes([NSAttributedStringKey.font: UIFont(name: "Helvetica Bold", size: 11.0)!, NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0.9019607843, green: 0.1960784314, blue: 0.1960784314, alpha: 1)], range: NSRange(location: 0, length: slash.length))
        }

        combination.append(slash)

        let strBoys = NSMutableAttributedString(string: boys)
        strBoys.addAttributes([NSAttributedStringKey.font: UIFont(name: "Helvetica Bold", size: 11.0)!, NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0.9019607843, green: 0.1960784314, blue: 0.1960784314, alpha: 1)], range: NSRange(location: 0, length: boys.length))
        combination.append(strBoys)

        return combination

    }

    static func setAttributedStringForEventDetailAddress(street1: String, street2: String) -> (NSMutableAttributedString?, CGFloat) {

        let combinedStr = street1 + " & " + street2
        let htRequiredForAddress = combinedStr.height(withConstrainedWidth: appDelegate.window!.screen.bounds.width - 50, font: UIFont(name: "Helvetica Bold", size: 14.0)!) + 5

        let combination = NSMutableAttributedString()
        combination.append(NSAttributedString(string: street1.uppercased()))
        combination.addAttributes([NSAttributedStringKey.font: UIFont(name: "Helvetica Bold", size: 14.0)!, NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0.9019607843, green: 0.1960784314, blue: 0.1960784314, alpha: 1)], range: NSRange(location: 0, length: street1.length))

        let andSymbol = NSMutableAttributedString(string: " & ")
        andSymbol.addAttributes([NSAttributedStringKey.font: UIFont(name: "Helvetica Bold", size: 14.0)!, NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0.2039215686, green: 0.2039215686, blue: 0.2039215686, alpha: 1)], range: NSRange(location: 0, length: andSymbol.length))
        combination.append(andSymbol)

        let strStreet2 = NSMutableAttributedString(string: street2.uppercased())
        strStreet2.addAttributes([NSAttributedStringKey.font: UIFont(name: "Helvetica Bold", size: 14.0)!, NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0.8862745098, green: 0.4156862745, blue: 0.1254901961, alpha: 1)], range: NSRange(location: 0, length: street2.length))
        combination.append(strStreet2)

        return (combination, htRequiredForAddress)

    }

    static func getDateFormat() -> DateFormatter {

        let dateFormat = DateFormatter()
        dateFormat.dateFormat = AppConstants.eventDateTimeFormat

        return dateFormat
    }

    static func hideNavigationBottomLine() {
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().isTranslucent = false
    }

    /// Device token return in case f simulator static return
    ///
    /// - Returns: value of token
    static func getDeviceToken() -> String {
        if let value = KeychainWrapper.standard.string(forKey: AppConstants.userDeviceTokenKeyChain) {
            print("FCM Token: \(value)")
            return value
        } else {
            return "0"
        }
    }

    static func getDateString(from date: Date, format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale
        dateFormatter.dateFormat = format
        let strDate = dateFormatter.string(from: date)
        return strDate
    }
}
