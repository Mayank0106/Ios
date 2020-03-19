//
//  ViewController.swift
//  Zepplin
//
//  Created by Mayank Sharma on 25/02/20.
//  Copyright © 2020 Mayank Sharma. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController, UITextFieldDelegate  {
    
    @IBOutlet weak var Emailtxt: UITextField!
    @IBOutlet weak var Pwdtxt: UITextField!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblDescription1: UILabel!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        lblDescription.isHidden = true
        self.Emailtxt.delegate = self
        self.Pwdtxt.delegate = self
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func SignInbtn(_ sender: Any) {
        lblDescription.isHidden = true
        lblDescription1.isHidden = true
        
        
        guard let userName = self.Emailtxt.text,
            let password = self.Pwdtxt.text else { return }
        
        /*let keychain = KeychainSwift()
        keychain.accessGroup = "123ABCXYZ.iOSAppTemplates"
        keychain.set(userName, forKey: "userName")
        keychain.set(password, forKey: "password")*/
        
        guard let email = Emailtxt.text, Emailtxt.text?.characters.count !=
            0 else {
                lblDescription.isHidden = false
                lblDescription1.text = "Please enter your Email"
                return
        }
        if isValidEmail(emailID: email) == false {
            lblDescription.isHidden = false
            lblDescription.text = "Please enter valid Email address"
            
        }
        
        guard let Password = Pwdtxt.text,
            Pwdtxt.text?.characters.count != 0 else {
                lblDescription1.isHidden = false
                lblDescription1.text = "Please enter your Password"
                return
        }
        if isValidPassword(Pwd: Password) == false {
              lblDescription1.isHidden = false
              lblDescription1.text = "Please Enter a Valid Password"
            }
        self.callSignInWebService()
    }
  
    func isValidEmail(emailID:String) ->Bool {
        let  emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9,-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: emailID)
    }
    
    
   func isValidPassword(Pwd:String) -> Bool {
        let passwordRegex = "^(?=.*\\d)(?=.*[a-z])(?=.*[A-Z])[0-9a-zA-Z!@#$%^&*()\\-_=+{}|?>.<,:;~`’]{8,}$"
        let PasswordTest = NSPredicate(format:"SELF MATCHES %@", passwordRegex)
        return PasswordTest.evaluate(with:Pwd)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
extension SignInViewController: SignInAPI {
    /// Create Device Info Object
    ///
    /// - Returns: Device Info Object
    func createDeviceInfoObject() -> DeviceInfo {
        
        var deviceInfo = DeviceInfo()
        
        let strDeviceID = UIDevice.current.identifierForVendor?.uuidString
        deviceInfo.deviceId = strDeviceID
        deviceInfo.deviceType = 2 // for iPhone
        deviceInfo.deviceToken = "2347823478989423789234789234789"
        deviceInfo.deviceOS = UIDevice.current.systemVersion
        return deviceInfo
        
    }
    
    // MARK: - Create User model
    
    /// Create User Model
    ///
    /// - Returns: user model
    func createUserModel() -> UserDeviceModel {
        
        var userDeviceInfo = UserDeviceModel()
        
        userDeviceInfo.username = Emailtxt.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        userDeviceInfo.password = Pwdtxt.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let deviceInfo = self.createDeviceInfoObject()
        userDeviceInfo.deviceId = deviceInfo.deviceId
        userDeviceInfo.deviceToken = deviceInfo.deviceToken
        userDeviceInfo.deviceType = deviceInfo.deviceType
        
        return userDeviceInfo
    }
    
    // MARK: - Web Service Calls
    
    /// Web service call to sign in and get user token
    func callSignInWebService() {
        
        let userDeviceInfo = createUserModel()
        
        self.signIn(userDeviceInfo, withHandler: { (userDetails, isFromCache)  in
            guard let userInfo = userDetails else { return }
        }) { (error) in
        }
    }
}






