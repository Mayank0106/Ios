//
//  SettingsVC.swift
//  Reach
//
//  Copyright © 2019 Netsolutions. All rights reserved.
//

import UIKit

class SettingsVC: UIViewController, SignInAPI {

    // MARK: - IBOutlets
    @IBOutlet weak var btnNotificationSwitch: UIButton!

    // MARK: - Variables
    var objPageToOpen: PageToOpen?

    @IBOutlet weak var vwNotification: UIView!
    // MARK: - View controller life cycle
    override func viewDidLoad() {

        super.viewDidLoad()
        if let data = KeychainWrapper.standard.object(forKey: AppConstants.userModelKeyChain),
            let userObj = data as? UserModel {

            if let isNotificationAllowed = userObj.isNotificationAllowed {
               self.btnNotificationSwitch.isSelected = isNotificationAllowed
            }
        }
        // Do any additional setup after loading the view.
        self.btnNotificationSwitch.isUserInteractionEnabled = false
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(gesture:)))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
    }
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                _ = self.navigationController?.popViewController(animated: true)
            default:
                break
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        setNavBarHide(hide: true)
    }
    // MARK: - Set UI
    /// Make Service Calls As per notification Settings
    func makeServiceCallAsPerNotificationSetting() {
        if btnNotificationSwitch.isSelected {
            callWebserviceToChangeNotificationSettings(toAllow: 0)
        } else {
            let isRegisteredForRemoteNotifications = UIApplication.shared.isRegisteredForRemoteNotifications
            if isRegisteredForRemoteNotifications {
                // User is registered for notification
                callWebserviceToChangeNotificationSettings(toAllow: 1)
            } else {
                // Show alert user is not registered for notification
                print("Notifictaion allowed is false")
                let refreshAlert = UIAlertController(title: "Push Notification Service Disable ,please enable it.", message: nil, preferredStyle: UIAlertControllerStyle.alert)
                refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                    if let url = NSURL(string: UIApplicationOpenSettingsURLString) as URL? {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }))
                refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                    print("Handle Cancel Logic here")
                }))
                present(refreshAlert, animated: true, completion: nil)
            }
        }
    }

    // MARK: - Web service calls

    /// Web service call to logout
    func callWebserviceToLogOut() {

        if !AppUtility.isNetworkAvailable() {
            AppUtility.showAlert("",
                                 message: "NetworkError".localized,
                                 delegate: self)
            return
        }

        logOut( withHandler: { (userDetails, isFromCache)  in

            guard let userInfo = userDetails else { return }

            if userInfo.status == AppConstants.successServiceCode {

                if let data = KeychainWrapper.standard.object(forKey: AppConstants.userModelKeyChain),
                    let userObj = data as? UserModel,
                    let userID = userObj.id {

                    ChatUser.logOutUser(userId: userID,
                                        fcmTokenKey: "",
                                        completion: { (response) in
                        print(response)
                    })
                }
                appDelegate.navigationToLoginIfAppTokenNotAvailableOrLogOut()

            } else if userInfo.status == AppConstants.tokenExpired {

                appDelegate.navigationToLoginIfAppTokenNotAvailableOrLogOut()
            } else {
                AppUtility.showAlert("",
                                     message: userInfo.message,
                                     delegate: nil)
            }
        }) { (error) in
            AppUtility.showAlert("",
                                 message: "Error",
                                 delegate: nil)
        }
    }

    /// Web service call to change notification settings
    ///
    /// - Parameter toAllow: to allow/not allow
    func callWebserviceToChangeNotificationSettings(toAllow: Int) {
        if !AppUtility.isNetworkAvailable() {
            AppUtility.showAlert("",
                                 message: "NetworkError".localized,
                                 delegate: self)
            return
        }
        vwNotification.isUserInteractionEnabled = false

        // Call webservice
        changeNotificationSettings(toAllow: toAllow,
                                   withHandler: { (userDetails, isFromCache)  in
                                    self.vwNotification.isUserInteractionEnabled = true
            guard let userInfo = userDetails else {
                return }

            if userInfo.status == AppConstants.successServiceCode {
                self.btnNotificationSwitch.isSelected = !self.btnNotificationSwitch.isSelected
                if let data = KeychainWrapper.standard.object(forKey: AppConstants.userModelKeyChain),
                    let userObj = data as? UserModel {
                   userObj.isNotificationAllowed = self.btnNotificationSwitch.isSelected
                   KeychainWrapper.standard.set(userObj, forKey: AppConstants.userModelKeyChain)
                }
            } else if userInfo.status == AppConstants.tokenExpired {
                appDelegate.navigationToLoginIfAppTokenNotAvailableOrLogOut()
            } else {
                AppUtility.showAlert("", message: userInfo.message, delegate: nil)
            }
        }) { (error) in
            AppUtility.showAlert("", message: "Error", delegate: nil)
        }
    }

    // MARK: - IBActions
    @IBAction func btnChangePasswordAction(_ sender: Any) {

        self.performSegue(withIdentifier: "fromSettingsToChangePassword",
                          sender: nil)
    }

    @IBAction func btnTermsAndConditionsAction(_ sender: Any) {

        objPageToOpen = .terms
        self.performSegue(withIdentifier: "fromSettingsToWebViewVC",
                          sender: nil)
    }

    @IBAction func btnPrivacyPolicyAction(_ sender: Any) {

        objPageToOpen = .privacy
        self.performSegue(withIdentifier: "fromSettingsToWebViewVC",
                          sender: nil)
    }

    @IBAction func btnAllowNotifications(_ sender: Any) {
       makeServiceCallAsPerNotificationSetting()
    }

    @IBAction func btnNotificationSwitchAction(_ sender: Any) {
        makeServiceCallAsPerNotificationSetting()
    }

    @IBAction func btnLogOutAction(_ sender: Any) {
        callWebserviceToLogOut()
    }

    @IBAction func btnAboutUsAction(_ sender: Any) {
        objPageToOpen = .aboutUs
        self.performSegue(withIdentifier: "fromSettingsToWebViewVC",
                          sender: nil)
    }

    @IBAction func btnDoneAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    // MARK: - Prepare For Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "fromSettingsToWebViewVC" {

            guard let webViewVC = segue.destination
                as? WebViewVC else { return }
            webViewVC.objPageToOpen = objPageToOpen
        }
    }
}
