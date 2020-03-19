//
//  ViewController.swift
//  Push Notifications
//
//  Created by Mayank Sharma on 23/01/20.
//  Copyright © 2020 Mayank Sharma. All rights reserved.
//

import UIKit
import UserNotifications

class ViewController: UIViewController {

    @IBAction func Action(_ sender: Any) {
        let content = UNMutableNotificationContent()
        content.title = "The 5 Seconds Are up!"
        content.subtitle = "They are up now!"
        content.body = "The 5 seconds are really up!"
        content.badge = 1
        
        let Trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats : false )
        
        let request = UNNotificationRequest(identifier: "timerdone", content : content, trigger : Trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        UNUserNotificationCenter.current().requestAuthorization(options: [ .alert, .sound, .badge], completionHandler: { didAllow, error in
            
          
            
        })
    
    
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

