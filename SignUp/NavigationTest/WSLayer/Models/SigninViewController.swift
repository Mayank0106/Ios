//
//  SigninViewController.swift
//  NavigationTest
//
//  Created by Mayank Sharma on 11/02/20.
//  Copyright © 2020 Mayank Sharma. All rights reserved.
//

import UIKit

class SigninViewController: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var lblValidationMessage1: UILabel!
    @IBOutlet weak var txtEmail: UITextField!
    
    @IBOutlet weak var txtPassword: UITextField!
    
    @IBOutlet weak var lblValidationMessage: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
         // Do any additional setup after loading the view.
        
        lblValidationMessage.isHidden = true
        
        self.txtEmail.delegate = self
        self.txtPassword.delegate = self
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    
    @IBAction func LoginUser(_ sender: Any)
    {
      lblValidationMessage.isHidden = true
     lblValidationMessage1.isHidden = true
    
        
        guard let email = txtEmail.text, txtEmail.text?.characters.count !=
               0 else {
                lblValidationMessage.isHidden = false
                lblValidationMessage.text = "Please enter your Email"
                return
        }
        if isValidEmail(emailID: email) == false {
            lblValidationMessage.isHidden = false
            lblValidationMessage.text = "Please enter valid Email address"
            
        }
        
        guard let Password = txtPassword.text,
            txtPassword.text?.characters.count != 0 else {
                lblValidationMessage1.isHidden = false
                lblValidationMessage1.text = "Please enter your Company Id"
                return
        }
        
    }
    
    func isValidEmail(emailID:String) ->Bool {
        let  emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9,-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: emailID)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
extension SigninViewController: SignInAPI {
  /// Create Device Info Object
 ///
    /// - Returns: Device Info Object
    func createDeviceInfoObject() -> DeviceInfo{
        var deviceInfo = DeviceInfo()
        
        
        let strDeviceID = UIDevice.current.identifierForVendor?.uuidString
        deviceInfo.deviceId = strDeviceID
        deviceInfo.deviceType = 2// for  iphone
        deviceInfo.deviceToken = "2322465456454545848647664"
        return deviceInfo
    }
    /// MARK: - Create User model
    ///
    /// - Returns: user model
    
    func createUserModel() -> UserDeviceModel {
        
         var userDeviceInfo = UserDeviceModel()
        
        
        userDeviceInfo.username = txtEmail.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        userDeviceInfo.password = txtpassword.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
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
    


    
    /*USER DEFAULT SYNTAX
     let defaults = UserDefaults.standard
     defaults.set(25, forKey: "Age")
     defaults.set(true, forKey: "UseFaceID")
     defaults.set(CGFloat.pi, forKey: "Pi")
     defaults.set(CGFloat.pi, forKey: "Pi")
     
     defaults.set("Mayank", forKey: "Name")
     defaults.set(Date(), forKey: "LastRun")
     
     let array = ["Hello","World"]
     defaults.set(array, forKey: "SavedArray")
     
     let dict  = ["Name": "Mayank", "Country": "India"]
     defaults.set(dict, forKey: "SavedDict")
     
     let savedInteger = defaults.integer(forKey: "Age")
     let savedBoolean = defaults.bool(forKey: "UseFaceID")
     let savedArray =  defaults.object(forKey: "SavedArray") as? [String] ??
     [String] ()
     let savedDictionary = defaults.object(forKey: "SavedDictionary") as? [String : String] ?? [String : String]()    */
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
