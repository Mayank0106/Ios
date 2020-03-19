//
//  AppDelegateWebServiceCalls.swift
//  Reach
//
//  Created by Aanchal Jain on 12/03/19.
//  Copyright © 2019 Netsolutions. All rights reserved.
//

import Foundation
extension AppDelegate: AccessTokenAPI, SignInAPI {
    
    // MARK: - Check If User Model Exists
    // Call to check if there is a need to call Auth token service
    func checkToCallkeyTokenService(handler: @escaping (_ isCompleted: Bool?) -> Void ) {
        if KeychainWrapper.standard.object(forKey: AppConstants.appTokenKeyChain) == nil {
            self.callAppTokenService(false, completionHandlerForTokenExpire: { (isCompleted) in
                handler(isCompleted)
            })
        } else {
            if let tokenObj = KeychainWrapper.standard.object(forKey: AppConstants.appTokenKeyChain) {
                if let appTokenObj = tokenObj as? AccessToken, let token = appTokenObj.accessToken {
                    Configuration.customHeaders["Authorization"] = "Bearer \(token)"
                    print("Bearer \(token)")
                    handler(true)
                }
            }
        }
        /*
         if UserDefaults.standard.bool(forKey: "isLoggedIn") {
         if let appToken = KeychainWrapper.standard.string(forKey: AppConstants.appTokenKeyChain) {
         if let data = KeychainWrapper.standard.object(forKey: AppConstants.userModelKeyChain),
         let userObj = data as? UserModel {
         if let userToken = userObj.accessToken {
         Configuration.customHeaders["Authorization"] = "Bearer \(appToken)"
         Configuration.customHeadersUserToken["Authorization"] = "Bearer \(userToken)"
         appDelegate.setTabBar()
         }
         }
         } } else {
         self.callAppTokenService(false, completionHandlerForTokenExpire: { (isCompleted) in
         handler(isCompleted)
         })
         }*/
    }
    
    // MARK: - Web Service Calls

    /// Call App Token Service with Predefined User Name and Password for Resource Security
    ///
    /// - Parameters:
    ///   - isPublicTokenCall: True/false
    ///   - completionHandlerForTokenExpire: completion handler
    func callAppTokenService(_ isPublicTokenCall: Bool,
                             completionHandlerForTokenExpire: @escaping CompletionHandlerForTokenExpire) {

        //Check Network
        if !AppUtility.isNetworkAvailable() {
            AppUtility.showAlert("",
                                 message: "NetworkError".localized,
                                 delegate: self)
            completionHandlerForTokenExpire(false)
            return
        }

        // Get Token Webservice
        self.getToken(withHandler: { (appTokenObj) in

            guard let appToken = appTokenObj else {
                AppUtility.showAlert("",
                                     message: "AccessTokenFail".localized,
                                     delegate: self)
                completionHandlerForTokenExpire(false)
                return
            }

            // Set APP Token In Key Chain & Constants
            if let accessToken = appToken.accessToken {
                _ = KeychainWrapper.standard.set(appToken, forKey: AppConstants.appTokenKeyChain)
                Configuration.customHeaders["Authorization"] = "Bearer \(accessToken)"
                print("Bearer \(accessToken)")
                completionHandlerForTokenExpire(true)
            }
        })
    }

    /// Web service call to change notification settings
    ///
    /// - Parameter toAllow: to allow/not allow
    func callWebserviceToChangeNotificationSettings(toAllow: Bool) {

        if !AppUtility.isNetworkAvailable() {
            AppUtility.showAlert("", message: "NetworkError".localized, delegate: self)
            return
        }
        var notificationAllow = 0
        if toAllow {
            notificationAllow = 1
        } else {
            notificationAllow = 0
        }
        changeNotificationSettings(toAllow: notificationAllow,
                                   withHandler: { (userDetails, isFromCache)  in

                                    guard let userInfo = userDetails else { return }
                                    if userInfo.status == AppConstants.successServiceCode {
                                        print("Notifications status updated succfully")
                                        if let data = KeychainWrapper.standard.object(forKey: AppConstants.userModelKeyChain),
                                            let userObj = data as? UserModel {
                                            userObj.isNotificationAllowed = toAllow
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
    
    // MARK: Check App update Available or Not
    func callAPIToCheckAppUpdate() {
        //Check Network
        if !AppUtility.isNetworkAvailable() {
            AppUtility.showAlert("", message: "NetworkError".localized, delegate: self)
            return
        }
        
        //Get App Version
        let versionNumber: Int =  1
        // Check App Version upudate
        self.checkAppVersionUpdate(appVersion: versionNumber, withHandler: { (responseData) in
            // If Token expire Then Get again
            if let tokenExpire =  responseData?.status, tokenExpire == AppConstants.tokenExpired {
                if AppUtility.getAppDelegate()?.isAppToken() ?? true {
                    // access token expire
                    AppUtility.getAppDelegate()?.callAppTokenService(true, completionHandlerForTokenExpire: { (isSaved) in
                        if isSaved {
                            self.callAPIToCheckAppUpdate()
                        }
                    })
                }
                return
            }
            // If Token expire Then Get again
            if let tokenExpire =  responseData?.status, tokenExpire == AppConstants.noVersionAvailable {
                return
            }
            
            guard let appDetailObj = responseData?.response else {
                AppUtility.showAlert("", message: (responseData?.message)!, delegate: self)
                return
            }
            
            if let checkUpdate = appDetailObj.version_check {
                if checkUpdate == Enums.VersionType.VERSION_NOT_SUPPORTED.rawValue {
                    self.isUpdateAvailable = true
                    let alertView = UIAlertController(title: "AppUpdateTitle".localized, message: "ForceUpdateText".localized, preferredStyle: .alert)
                    let action = UIAlertAction(title: "UpdateTitle".localized, style: .default, handler: { (_) in
                        self.openItunesLinkToDownloadApp()
                    })
                    alertView.addAction(action)
                    self.window?.rootViewController!.present(alertView, animated: true, completion: nil)
                } else if checkUpdate == Enums.VersionType.VERSION_UPGRADE_AVAILABLE.rawValue {
                    self.isUpdateAvailable = false
                    let alertView = UIAlertController(title: "AppUpdateTitle".localized, message: "UpdateAvailabelText".localized, preferredStyle: .alert)
                    let action = UIAlertAction(title: "UpdateTitle".localized, style: .default, handler: { (_) in
                        self.openItunesLinkToDownloadApp()
                    })
                    let cancelAction = UIAlertAction(title: "LaterTitle".localized, style: .cancel, handler: { (_) in
                    })
                    alertView.addAction(action)
                    alertView.addAction(cancelAction)
                    self.window?.rootViewController!.present(alertView, animated: true, completion: nil)
                } else {
                    //print("No app updates")
                    self.isUpdateAvailable = false
                }
            }
        })
    }
    
    func openItunesLinkToDownloadApp() {
        if let reviewURL = URL(string: "itms-apps://itunes.apple.com/"), UIApplication.shared.canOpenURL(reviewURL) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(reviewURL, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(reviewURL)
            }
        }
    }
    
    // MARK: handleError popup
    /// Handle Error in case of error
    ///
    /// - Parameter error: error
    func handleError(error: NSIError) {
        if let errorDict = error.response as? [String: String], let errorMessage = errorDict[AppConstants.errorDescription] {
            AppUtility.showAlert("", message: errorMessage, delegate: self)
        } else if let errorDict = error.response as? [String: Any], let errorDeatilDict = errorDict[AppConstants.error] as? [String: String], let errorMessage = errorDeatilDict[AppConstants.errorDetail] {
            AppUtility.showAlert("", message: errorMessage, delegate: self)
        } else if error.error != nil {
            AppUtility.showAlert("", message: (error.error?.localizedDescription)!, delegate: self)
        }
    }
    // MARK: App Token service
    // Check if the token which is expired is App token or User Token
    func isAppToken() -> Bool {
        let apptokenObj = KeychainWrapper.standard.object(forKey: AppConstants.appTokenKeyChain) as? AccessToken
        let appToken = "Bearer \(apptokenObj?.accessToken ?? "")"
        // Checking if token used in API call matches with app token or not
        // If matches, then token is app token
        // If not, token is user token
        return (appToken == Configuration.customHeaders["Authorization"])
    }
}
