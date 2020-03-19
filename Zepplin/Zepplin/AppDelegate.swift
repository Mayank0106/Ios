//
//  AppDelegate.swift
//  Zepplin
//
//  Created by Mayank Sharma on 25/02/20.
//  Copyright © 2020 Mayank Sharma. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, AccessTokenAPI {

    var window: UIWindow?
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        self.fetchToken()
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

//    func fetchToken() {
//        self.getToken("clSKkYWFMwd2I3idyJ4oAJlpOrCnZGN23s8CtRQD", clientSecret: "Xrcf4r7bypPKUPiik6dbcCzaDopErpZIkgHIqoFj6bTKlDnxiP35odlSJX1m5MjK0k6VMqPs2G7UN8gswKJ80", grantType: "password", username: "appuser@mailinator.com", password: "Admin@1234") { (isCompleted) in
//            print(isCompleted)
//
//        }
//    }
    
    func fetchToken() {
        self.getToken(clientId: "kmgfcwb6gbdOQAr9YGhpBRI0RXQAymeJzTqB3h95", clientSecret: "wAhdIPG7ZU5ah7bdCc1joCukzMwmhbYKAY0BnD8nRoIDInry84Gz8jZEM3cm7RgSejU3aDtMNF0yx9YU7z5x00JYcxpEo24sjV8kL4mhGs9jjb4OYfgah2o3q3HUK2On", grantType: "password", username: "bor_appuser@borevent.com", password: "15@bor_5#eventapp") { (isCompleted) in
            print("isCompleted \(String(describing: isCompleted))")
            if let appTokenObj = isCompleted, let token = appTokenObj.accessToken {
                Configuration.customHeaders["Authorization"] = "Bearer \(token)"
                print("Bearer \(token)")
            }
            
        }
    }
    
    
    /* func setRootVC() {
        if UserDefaults.standard.bool(forKey: "isLoggedIn") {
            if let data = KeychainWrapper.standard.object(forKey: AppConstants.userModelKeyChain),
                let userObj = data as? UserModel {
                if let userToken = userObj.accessToken {
                    Configuration.customHeadersUserToken["Authorization"] = "Bearer \(userToken)"
                }
            }
        }
    } */
    
    

}





