//
//  AppDelegate.swift
//  Reach
//
//  Copyright © 2017 Netsolutions. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import SCSDKLoginKit
import UserNotifications
import Firebase
import FirebaseMessaging
import Contacts

import Fabric
import Crashlytics


typealias CompletionHandlerForTokenExpire = (_ complete: Bool) -> Void

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    // MARK: - Variables
    var window: UIWindow?
    var notificationExists: Bool = false
    var isNotificationAllowed: Bool = false
    var isUpdateAvailable: Bool = false

    // MARK: Contact syncing
    var contactStore = CNContactStore()
    var maxPageLimit: Int = 1
    var currentPage: Int = 1
    var arrayForUpload: [[String]] = []
    var chunkSize: Int = 10

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        //initial app setup
        initialSetup()
        if #available(iOS 13.0, *) {
            window?.overrideUserInterfaceStyle = .light
        }
        Fabric.with([Crashlytics.self])
        // Push notification
        registerForPushNotification(application: application)

        // badge
        setBadgeValue()
        window?.makeKeyAndVisible()
        return true
    }

    // MARK: - Initial App Setup

    /// Set Up
    func initialSetup() {
        Thread.sleep(forTimeInterval: 3)
        AppUtility.hideNavigationBottomLine()
        FirebaseApp.configure()
        AppUtility.removeKeyChainValues()

        //S3 Bucket
        AppUtility.setS3Bucket()

        // IQKeybaord
        AppUtility.setIQKeyBoardManager()

        // Set Naviagtion
        AppUtility.setNavBarAppearance()

        //Set Text Cursor
        AppUtility.setTextFieldCursor()

        // To check call service or not and perform calling if required
        // Check App token API Call
        checkToCallkeyTokenService(handler: { (isCompleted) in
            if let isComplete = isCompleted, isComplete == true {
                self.callAPIToCheckAppUpdate()
            }
        })
        
        // Set Root View Controller
        self.setRootVC()
    }
    
    
    func setRootVC() {
        if UserDefaults.standard.bool(forKey: "isLoggedIn") {
            if let data = KeychainWrapper.standard.object(forKey: AppConstants.userModelKeyChain),
                let userObj = data as? UserModel {
               if let userToken = userObj.accessToken {
                    Configuration.customHeadersUserToken["Authorization"] = "Bearer \(userToken)"
                    // Set TabBar as root
                    appDelegate.setTabBar()
                }
            }
        }
    }

    // Push Notification Badge
    func setBadgeValue() {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state.
        //This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message)
        //or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks.
        //Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers,
        //and store enough application state information to restore your application
        //to its current state in case it is terminated later.
        // If your application supports background execution,
        //this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state;
        //here you can undo many of the changes made on entering the background.
        if self.isUpdateAvailable {
            callAPIToCheckAppUpdate()
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive.
        //If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate.
        //Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {
        return SCSDKLoginClient.application(app, open: url, options: options)
    }

    // MARK: - Register/Recieving Push Notifications

    /// Register ForPush Notifications
    ///
    /// - parameter application: UIApplication instance
    func registerForPushNotification(application: UIApplication) {

        // iOS 10 support & higher
        if #available(iOS 10, *) {
            UNUserNotificationCenter.current().delegate = self
            UNUserNotificationCenter.current()
                .requestAuthorization(options: [.badge, .alert, .sound]) { (granted, error)  in
                self.isNotificationAllowed = granted
                    print("Notification allowed in settings or user has")
                DispatchQueue.main.async(execute: {
                    application.registerForRemoteNotifications()
                })
            }
        }
        Messaging.messaging().delegate = self
    }

    // Delegate called if registration for remote notification failed
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("i am not available in simulator \(error)")
    }

    // MARK: - Push Notifications recieved
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping
                                (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
        NSLog("Userinfo willPresent: %@", notification.request.content.userInfo)
    }

    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {

        NSLog("Userinfo didReceive: %@", response.notification.request.content.userInfo)

        guard let notificationBody = response.notification.request.content.userInfo["body"] as? String else { return }
        let strRemovedSlashes = notificationBody.replacingOccurrences(of: "\\", with: "")
        let data = strRemovedSlashes.data(using: .utf8)!

        do {
            if let jsonResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {

                for (key, _) in jsonResult where key == "event_id" {

                    guard let eventID = jsonResult[key] as? Int else { return }
                    print(eventID)
                    self.openEventDetailViewController(eventID: eventID)
                }
            }
            catch let
            
        } catch let error {
            print(error.localizedDescription)
        }
        completionHandler()
    }

    /// Open Event Detail
    ///
    /// - Parameter eventID: Event ID
    func openEventDetailViewController(eventID: Int) {
        
        if let tabbar = appDelegate.window?.rootViewController as? UITabBarController {
            tabbar.selectedIndex = 0
            guard let navController = tabbar.viewControllers?[0]
                as? UINavigationController else { return }
            navController.dismiss(animated: true,
                                  completion: nil)
            guard let eventDetail = tabBarStoryboard.instantiateViewController(withIdentifier: "EventDetailVC")
                as? EventDetailVC else { return }
            eventDetail.eventID = eventID
            navController.pushViewController(eventDetail,
                                             animated: true)
        }
    }


    // MARK: - Saving/Removing User Details

    /// Save User Details on Login
    ///
    /// - Parameter response: response
    func saveUserDetailsOnLogin(response: UserModel) {
        UserDefaults.standard.set(true, forKey: "isLoggedIn")
        guard let accessToken = response.accessToken else { return }
        Configuration.customHeadersUserToken["Authorization"] = "Bearer \(accessToken)"
        KeychainWrapper.standard.set(response, forKey: AppConstants.userModelKeyChain)

        // Set Tab Bar
        setTabBar()
        
        // For getting contacts
        checkContactsAvailability()
        var arrPositionChangeStore: [String]! = []
        arrPositionChangeStore = AppUtility.getContacts()
        if arrPositionChangeStore.isEmpty {
            
            return
        }
        // Genrate page array
        generatePageArray(arrAllContacts: arrPositionChangeStore)
    }

    /// Remove User Settings
    func removeUserSettings() {
        UserDefaults.standard.removeObject(forKey: "isLoggedIn")
        Configuration.customHeadersUserToken.removeValue(forKey: "Authorization")
        KeychainWrapper.standard.removeObject(forKey: AppConstants.userModelKeyChain)
        
    }

    // MARK: - Navigate to login if app token Not Available/Log Out
    /// Navigation to login if app token not available/Log out
    func navigationToLoginIfAppTokenNotAvailableOrLogOut() {
        guard let navController = appStoryboard.instantiateViewController(withIdentifier: "mainNavController")
            as? UINavigationController else { return }
        removeUserSettings()
        appDelegate.window?.rootViewController = navController
    }

    // MARK: - Set Tab Bar Appearance & Actions

    /// Set Tab Bar
    func setTabBar() {
        if let tabBarStoryboard = tabBarStoryboard.instantiateViewController(withIdentifier: "tabBarStoryboard")
            as? UITabBarController {
            tabBarStoryboard.tabBar.layer.shadowOffset = CGSize(width: 0,
                                                                height: 0)
            tabBarStoryboard.tabBar.layer.shadowRadius = 15
            tabBarStoryboard.tabBar.layer.shadowColor = UIColor.black.cgColor
            tabBarStoryboard.tabBar.layer.shadowOpacity = 0.3
            tabBarStoryboard.tabBar.clipsToBounds = false
            appDelegate.window?.rootViewController = tabBarStoryboard
            setTabBarAppearance(objTabbar: tabBarStoryboard)
        }
    }

    /// Set Tab Bar Appearance
    ///
    /// - Parameter objTabbar: Tab Bar
    func setTabBarAppearance(objTabbar: UITabBarController) {
        let btnCreateParty = UIButton(type: .custom)
        let attributedStr = AppUtility.setAttributedStringForTabCreateParty(create: "CREATE\n",
                                                                            party: "PARTY")
        btnCreateParty.setAttributedTitle(attributedStr,
                                          for: .normal)
        btnCreateParty.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        btnCreateParty.titleLabel?.font = UIFont(name: "Helvetica Bold",
                                                 size: 9.0)
        btnCreateParty.addTarget(self,
                                 action: #selector(AppDelegate.createPartyAction),
                                 for: .touchUpInside)
        var frame = CGRect()
        frame.size.height = 64
        frame.size.width = appDelegate.window!.screen.bounds.width/4
        frame.origin.x = ceil(0.5 * (appDelegate.window!.screen.bounds.width - frame.size.width))
        frame.origin.y = -15
        btnCreateParty.frame = frame
//        btnCreateParty.setBackgroundImage(UIImage(named: "tabBarCreateParty"),
//                                          for: .normal)
        objTabbar.tabBar.addSubview(btnCreateParty)
    }

    /// Create Party Action
    @objc func createPartyAction() {
        guard let tabbarController = appDelegate.window?.rootViewController
            as? UITabBarController else { return }
        guard let defineEventVC = tabBarStoryboard.instantiateViewController(withIdentifier: "CreateEventNavController")
            as? UINavigationController else { return }
        defineEventVC.modalPresentationStyle = .overCurrentContext
        tabbarController.present(defineEventVC,
                                 animated: false,
                                 completion: nil)
    }
}

// MARK: - MessagingDelegate Methods
extension AppDelegate: MessagingDelegate {

    func messaging(_ messaging: Messaging,
                   didReceiveRegistrationToken fcmToken: String) {
        KeychainWrapper.standard.set(fcmToken,
                                     forKey: AppConstants.userDeviceTokenKeyChain)
    }

    func application(received remoteMessage: MessagingRemoteMessage) {
        print(remoteMessage.appData)
    }
}
