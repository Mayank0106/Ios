//
//  TabBarController.swift
//  NotificationListener
//
//  Created by Mayank Sharma on 05/02/20.
//  Copyright © 2020 Mayank Sharma. All rights reserved.
//
import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    
    let TabController1 = ViewController1()
    let TabController2 = ViewController2()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
        // Do any additional setup after loading the view, typically from a nib.
      self.viewControllers = [TabController1, TabController2]
    
    }
    
    
    
  //tab bar delegate
    func tabBarController(_tabBarController: UITabBarControllerDelegate, didSelect viewController: UIViewController){
        print("selected another view controller")
   }
}


