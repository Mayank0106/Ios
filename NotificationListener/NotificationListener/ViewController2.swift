//
//  ViewController2.swift
//  NotificationListener
//
//  Created by Mayank Sharma on 05/02/20.
//  Copyright © 2020 Mayank Sharma. All rights reserved.
//
import UIKit

class ViewController2: UIViewController {
    
    let settingSwitch : UISwitch = {
        let ss = UISwitch()
        ss.translatesAutoresizingMaskIntoConstraints = false
        ss.addTarget(self, action: #selector(handleSwitchStateChange), for: .valueChanged)
        return ss
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "view2"
        self.view.backgroundColor = .red


        view.addSubview(settingSwitch)
        settingSwitch.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        settingSwitch.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
    }
    @objc func handleSwitchStateChange(){
        NotificationCenter.default.post(name: NSNotification.Name(ViewController1.kSwitchStateChangedNotification), object: nil)

  }
}
