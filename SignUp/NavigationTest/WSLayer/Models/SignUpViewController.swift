//
//  SignUpViewController.swift
//  NavigationTest
//
//  Created by Mayank Sharma on 11/02/20.
//  Copyright © 2020 Mayank Sharma. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var lblValidationMessage2: UILabel!
    @IBOutlet weak var PhoneNumber: UITextField!
    @IBOutlet weak var FirstNametext: UITextField!
    @IBOutlet weak var LastNametext: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var CompId: UITextField!
    @IBOutlet weak var lblValidationMessage: UILabel!
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
       lblValidationMessage.isHidden = true
        lblValidationMessage2.isHidden = true
        self.txtEmail.delegate = self
        self.CompId.delegate = self
        self.PhoneNumber.delegate = self
        self.FirstNametext.delegate = self
        self.LastNametext.delegate = self
        
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    
    @IBAction func SignUpUser(_ sender: Any)
    {
         lblValidationMessage.isHidden = true
        
        guard let email = txtEmail.text, txtEmail.text?.characters.count !=
        0 else  {
                lblValidationMessage.isHidden = false
                lblValidationMessage.text = "Please enter your Email!!"
                return
        }
        
        guard let Company = CompId.text,
            CompId.text?.characters.count != 0 else {
                lblValidationMessage2.isHidden = false
                lblValidationMessage2.text = "Please enter your Company Id!!"
                return
        }
        


    func isValidEmail(emailID:String) ->Bool {
        let  emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9,-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: emailID)
    }
}


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}

