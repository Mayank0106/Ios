//
//  ViewController.swift
//  textfield through programming
//
//  Created by Mayank Sharma on 03/02/20.
//  Copyright © 2020 Mayank Sharma. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var imgVwTest: UIImageView!
    
    var a = 0
    @IBAction func btnChange(_ sender: UIButton) {
       // imgVwTest.image = UIImage(named : "second")
      
        
        if a == 1 {
            a = 0
        imgVwTest.image = UIImage(named: "second")
           
        }else {
               a = 1
            imgVwTest.image = UIImage(named: "first")
            
        }
    
    
    
    
        func viewDidLoad() {
        super.viewDidLoad()
        /*
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        imageView.backgroundColor = UIColor.red
        imageView.layer.cornerRadius = 8.0
        imageView.clipsToBounds = true
        */
        
        
        imgVwTest.backgroundColor = UIColor.red
        imgVwTest.layer.cornerRadius = 50
        imgVwTest.clipsToBounds = true
        imgVwTest.layer.borderColor =  UIColor.white.cgColor
        imgVwTest.layer.borderWidth =  2
        imgVwTest.clipsToBounds = true
 
         
        
     /*   var sampleTextField =  UITextField(frame: CGRect(x: 20, y: 100, width: 300, height: 40))
        sampleTextField.placeholder = "Enter first Name"
        sampleTextField.font = UIFont.systemFont(ofSize: 15)
        sampleTextField.autocorrectionType = UITextAutocorrectionType.no
        sampleTextField.keyboardType = UIKeyboardType.default
        sampleTextField.returnKeyType = UIReturnKeyType.done
        sampleTextField.delegate = self
        self.view.addSubview(sampleTextField)
        sampleTextField.backgroundColor = .yellow

        
        sampleTextField =  UITextField(frame: CGRect(x: 20, y: 160, width: 300, height: 40))
        sampleTextField.placeholder = "Enter Last Name"
        sampleTextField.font = UIFont.systemFont(ofSize: 15)
        sampleTextField.autocorrectionType = UITextAutocorrectionType.no
        sampleTextField.keyboardType = UIKeyboardType.default
        sampleTextField.returnKeyType = UIReturnKeyType.done
        sampleTextField.delegate = self
        self.view.addSubview(sampleTextField)
        sampleTextField.backgroundColor = .yellow
        
        
        sampleTextField =  UITextField(frame: CGRect(x: 20, y: 220, width: 300, height: 40))
        sampleTextField.placeholder = "Enter your E-mail"
        sampleTextField.font = UIFont.systemFont(ofSize: 15)
        sampleTextField.autocorrectionType = UITextAutocorrectionType.no
        sampleTextField.keyboardType = UIKeyboardType.emailAddress
        sampleTextField.returnKeyType = UIReturnKeyType.done
        sampleTextField.delegate = self
        self.view.addSubview(sampleTextField)
        sampleTextField.backgroundColor = .yellow
        
        
        
        sampleTextField =  UITextField(frame: CGRect(x: 20, y: 280, width: 300, height: 40))
        sampleTextField.placeholder = "Enter phone Number"
        sampleTextField.font = UIFont.systemFont(ofSize: 15)
        sampleTextField.autocorrectionType = UITextAutocorrectionType.no
        sampleTextField.keyboardType = UIKeyboardType.numberPad
        sampleTextField.returnKeyType = UIReturnKeyType.done
        sampleTextField.delegate = self
        self.view.addSubview(sampleTextField)
        sampleTextField.backgroundColor = .yellow
        
        
        
        
        }
    */
    
        // Do any additional setup after loading the view, typically from a nib.
    }

        func didReceiveMemoryWarning() {
        // Dispose of any resources that can be recreated.
    }
func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
}

   }



}
