//
//  RegisterViewController.swift
//  Zepplin
//
//  Created by Mayank Sharma on 26/02/20.
//  Copyright © 2020 Mayank Sharma. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var FirstNametxt: UITextField!
    @IBOutlet weak var LastName: UITextField!
    @IBOutlet weak var EMLtxt: UITextField!
    @IBOutlet weak var Pwddtxt: UITextField!
    @IBOutlet weak var Cnfmpwdtxt: UITextField!
    @IBOutlet weak var lbldesc: UILabel!
    @IBOutlet weak var lbldesc1: UILabel!
    
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        lbldesc.isHidden = true
        lbldesc1.isHidden = true
        self.EMLtxt.delegate = self
        self.Pwddtxt.delegate = self
        self.Cnfmpwdtxt.delegate = self
       
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    
    @IBAction func Regis(_ sender: Any) {
        lbldesc.isHidden = true
        lbldesc1.isHidden = true
        guard let email = EMLtxt.text, EMLtxt.text?.characters.count !=
            0 else {
                lbldesc.isHidden = false
                lbldesc.text = "Please enter your Email"
                return
        }
        if isValidEmail(emailID: email) == false {
            lbldesc.isHidden = false
            lbldesc.text = "Please enter valid Email address"
        
        }
   
    }
    
    func isValidEmail(emailID:String) ->Bool {
        let  emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9,-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: emailID)
    }
    
    
    
}

