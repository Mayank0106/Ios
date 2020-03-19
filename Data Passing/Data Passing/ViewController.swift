//
//  ViewController.swift
//  Data Passing
//
//  Created by Mayank Sharma on 10/02/20.
//  Copyright © 2020 Mayank Sharma. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var textField: UITextField!
    
    @IBAction func enter(_ sender: Any)
    {
        if textField.text != ""
        {
          performSegue(withIdentifier: "segue" , sender: self)
        }
 
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
      var secondController = segue.destination as! SecondViewController
        secondController.myString = textField.text!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}



