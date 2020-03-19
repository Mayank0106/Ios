//
//  SignInVC.swift
//  Reach
//
//  Copyright © 2018 Netsolutions. All rights reserved.
//

import UIKit
import SCSDKLoginKit

class SignInVC: UIViewController, SignInAPI {

    // MARK: - IBOutlets
    @IBOutlet weak var txtUsername: TextFontConstraint!

    @IBOutlet weak var txtPassword: TextFontConstraint!

    //Offline Views

    @IBOutlet var vwNext: UIView!

    @IBOutlet weak var btnNext: ButtonFontConstraint!

    // MARK: - Variables
    var strTextField = ""

    var isFromResetPassword: Bool = false

    var currentResponder: UITextField?

    // MARK: - View Controller life cycle
    override func viewDidLoad() {

        super.viewDidLoad()
        textFieldsSettings()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {

        if isFromResetPassword {
            setNavBar(title: "SignIn".localized, leftBarItem: .none, rightBarItems: [.none])
        } else {
            setNavBar(title: "SignIn".localized, leftBarItem: .backButton, rightBarItems: [.none])
        }
    }

    // MARK: - Initialization Methods

    /// Text Field Settings
    func textFieldsSettings() {

        txtUsername.inputAccessoryView = vwNext
        txtPassword.inputAccessoryView = vwNext

    }

    /// Move To Next Tsext Field
    func moveToNextTextField() {

        guard let currentTextField = currentResponder else { return }
        let tag = currentTextField.tag
        if let nextField = currentTextField.superview?.viewWithTag(tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            currentTextField.resignFirstResponder()
        }
    }

    // MARK: - Validate Fields

    /// Validate All Fields
    ///
    /// - Returns: Status
    func validateAllFields() -> (Bool, String?) {
        if txtUsername.text!.isEmpty || txtPassword.text!.isEmpty {
            return (false, "AllFieldsAreMandatory".localized)
        } else if txtUsername!.text!.count < AppConstants.minimumUsernameLength {
            return (false, "TooShortUsername".localized)
        } else if !AppUtility.isValidPassword(password: txtPassword.text!) {
            return (false, "PasswordRequirements".localized)
        }
        return (true, nil)
    }

    /// Validate Every Text Input
    ///
    /// - Parameter textField: Text Field
    func validateInput(textField: UITextField) {

        let strText = textField.text!.trimmingCharacters(in: .whitespacesAndNewlines)

        if textField == txtUsername {
            txtUsername.errorMessage = nil
            if strText.isEmpty {
                txtUsername.errorMessage = "UsernameIsMandatory".localized
                return
            }
            if strText.count < AppConstants.minimumUsernameLength {
                txtUsername.errorMessage = "TooShortUsername".localized
                return
            }
        }

        if textField == txtPassword {
            txtPassword.errorMessage = nil
            if strText.isEmpty {
                txtPassword.errorMessage = "PasswordIsMandatory".localized
                return
            }
            if !AppUtility.isValidPassword(password: strText) {
                txtPassword.errorMessage = "Password doesn't matches the criteria"
                return
            }
        }
    }

    // MARK: - Create User model

    /// Create User Model
    ///
    /// - Returns: user model
    func createUserModel() -> UserDeviceModel {

        var userDeviceInfo = UserDeviceModel()

        userDeviceInfo.username = txtUsername.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        userDeviceInfo.password = txtPassword.text!.trimmingCharacters(in: .whitespacesAndNewlines)

        let deviceInfo = AppUtility.createDeviceInfoObject()
        userDeviceInfo.deviceId = deviceInfo.deviceId
        userDeviceInfo.deviceToken = deviceInfo.deviceToken
        userDeviceInfo.deviceType = deviceInfo.deviceType

        return userDeviceInfo
    }

    // MARK: - Web Service Calls

    /// Web service call to sign in and get user token
    func callSignInWebService() {

        if !AppUtility.isNetworkAvailable() {
            AppUtility.showAlert("", message: "NetworkError".localized, delegate: self)
            return
        }

        let userDeviceInfo = createUserModel()

        signIn(userDeviceInfo, withHandler: { (userDetails, isFromCache)  in

            // If App Token expire Then Call GetAppToken Service again to get token
            if let tokenExpire =  userDetails?.status, tokenExpire == AppConstants.tokenExpired {

                AppUtility.getAppDelegate()?.callAppTokenService(true,
                                                                 completionHandlerForTokenExpire: { (isSaved) in
                    if isSaved {
                        //After getting Token call the same service again
                        self.callSignInWebService()
                    }
                })
                return
            }
            guard let userInfo = userDetails else { return }

            if userInfo.status == AppConstants.successServiceCode {
                guard let response = userInfo.response, let accessToken = response.accessToken else { return }
                print("Access Token =====", accessToken)
                appDelegate.saveUserDetailsOnLogin(response: response)
                self.signInWithFirebase(response: response)
            } else {
                AppUtility.showAlert("", message: userInfo.message, delegate: nil)
            }
        }) { (error) in
            AppUtility.showAlert("", message: "Error", delegate: nil)
        }
    }

    // MARK: Firebase SignIn
    func signInWithFirebase(response: UserModel) {

        ChatUser.signInWithEmail(email: response.email!, password: txtPassword.text!, userName: response.username!,
                                 userId: response.id!, userImage: response.profileImage!) { (success, message)  in
            if success {
                print("Logged In from firebase successfully")
            } else {
                //self.showAlertMessage("", message: message)
            }
        }
    }

    // MARK: - IBActions

    @IBAction func btnForgotPasswordAction(_ sender: Any) {

         performSegue(withIdentifier: StoryboardSegue.Main.toForgotPasswordVC.rawValue, sender: self)
    }

    @IBAction func btnSignInAction(_ sender: Any) {

        self.view.endEditing(true)

        let tuple = validateAllFields()
        if tuple.0 == true {
            self.callSignInWebService()
        } else if let errMsg = tuple.1 {
            AppUtility.showAlert("", message: errMsg, delegate: nil)
        }
    }

    @IBAction func btnNextAction(_ sender: Any) {

        let tuple = validateAllFields()
        if tuple.0 == true {
            self.callSignInWebService()
        } else if let _ = tuple.1 {
            moveToNextTextField()
        }
    }
}

// MARK: - UITextField delagate methods
extension SignInVC: UITextFieldDelegate {

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {

        currentResponder = textField
        return true
    }

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {

        let strText = textField.text! as NSString

        let newText = strText.replacingCharacters(in: range, with: string)

        if textField == txtUsername {

            if newText.length > AppConstants.maxUsernameLength {
                return false
            }
        } else if textField == txtPassword {

            if newText.length > AppConstants.maxPasswordLength {
                return false
            }
        }

        textField.text = newText
        return false
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        validateInput(textField: textField)
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let tag = textField.tag
        if let nextField = textField.superview?.viewWithTag(tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
}
