//
//  ViewController.swift
//  OTP Screen
//
//  Created by Mayank Sharma on 28/02/20.
//  Copyright © 2020 Mayank Sharma. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var txtOTP1: UITextField!
    @IBOutlet weak var txtOTP2: UITextField!
    @IBOutlet weak var txtOTP3: UITextField!
    @IBOutlet weak var txtOTP4: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtOTP1.delegate = self
        txtOTP2.delegate = self
        txtOTP3.delegate = self
        txtOTP4.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    
   
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range:NSRange, replacementString string: String) -> Bool {
        
        // Range.length == 1 means,clicking backspace
        if (range.length == 0){
            if textField == txtOTP1 {
                txtOTP2?.becomeFirstResponder()
            }
            if textField == txtOTP2 {
                txtOTP3?.becomeFirstResponder()
            }
            if textField == txtOTP3 {
                txtOTP4?.becomeFirstResponder()
            }
            if textField == txtOTP4 {
                txtOTP4?.resignFirstResponder()
            }
            textField.text? = string
            return false

        } else if (range.length == 1) {
            if textField == txtOTP4 {
                txtOTP3?.becomeFirstResponder()
            }
            if textField == txtOTP3 {
                txtOTP2?.becomeFirstResponder()
            }
            if textField == txtOTP2 {
                txtOTP1?.becomeFirstResponder()
            }
            if textField == txtOTP1 {
                txtOTP1?.resignFirstResponder()
            }
            textField.text? = ""
            return false
        }
            return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
    








