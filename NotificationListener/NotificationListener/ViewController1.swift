//
//  ViewController.swift
//  NotificationListener
//
//  Created by Mayank Sharma on 05/02/20.
//  Copyright © 2020 Mayank Sharma. All rights reserved.
//

import UIKit

class ViewController1: UIViewController {
    static let kSwitchStateChangedNotification = "kSwitchStateChangedNotification"
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "view1"
        self.view.backgroundColor = .blue
        self.registerNotifications()
    }
    
    func registerNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(handleStateChangeNotification), name: NSNotification.Name(ViewController1.kSwitchStateChangedNotification), object: nil)
    }
    
    @objc func handleStateChangeNotification(){
        self.view.backgroundColor = .red
    }
}
