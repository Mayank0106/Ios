//
//  ViewController.swift
//  UserDefault
//
//  Created by Mayank Sharma on 10/02/20.
//  Copyright © 2020 Mayank Sharma. All rights reserved.
//
import UIKit


class ViewController: UIViewController {
    @IBOutlet weak var segColour: UISegmentedControl!
    
  let userDefaults = UserDefaults.standard
    
    @IBAction func actColour(_ sender: UISegmentedControl) {
        print(segColour.selectedSegmentIndex)
            switch (segColour.selectedSegmentIndex)
        {
         
            case 0:
                self.view.backgroundColor = UIColor.red
            case 1:
                self.view.backgroundColor = UIColor.blue
            case 2:
                self.view.backgroundColor = UIColor.green
            default:
                self.view.backgroundColor = UIColor.red
        }
    }
    @IBAction func btnSave(_ sender: UIButton) {
        let bgColourNo = segColour.selectedSegmentIndex
        userDefaults.set( bgColourNo, forKey: "bgColour")
        userDefaults.synchronize()
    
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        var bgColourNo: Int? = userDefaults.object(forKey: "bgColour") as! Int?
        if(bgColourNo == nil) {
            bgColourNo = 1
            userDefaults.set(bgColourNo, forKey: "bgColour")
        }
        switch (bgColourNo!)
        {
         
        case 0:
            self.view.backgroundColor = UIColor.red
        case 1:
            self.view.backgroundColor = UIColor.blue
        case 2:
            self.view.backgroundColor = UIColor.green
        default:
            self.view.backgroundColor = UIColor.red
       
        
        }
        
        /* let instanceOfTableViewCell = TableViewCell()
        instanceOfTableViewCell.someProperty = "Hello World"
        print(instanceOfTableViewCell.someProperty)
        instanceOfTableViewCell.someMethod() */
    
        super.viewDidLoad()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


















