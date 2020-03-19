//
//  ResetPasswordVC.swift
//  Reach
//
//  Copyright © 2019 Netsolutions. All rights reserved.
//

import UIKit

class ResetPasswordVC: UIViewController, SignInAPI {

    // MARK: - IBOutlets
    @IBOutlet weak var txtPassword: TextFontConstraint!

    @IBOutlet weak var txtConfirmPassword: TextFontConstraint!

    //Offline Views

    @IBOutlet var vwNext: UIView!

    @IBOutlet weak var btnNext: ButtonFontConstraint!

    // MARK: - Variables
    var mobileNo: String?

    var currentResponder: UITextField?

    // MARK: - View Controller life cycle
    override func viewDidLoad() {

        super.viewDidLoad()
        textFieldsSettings()
       // enableNextButton(shouldEnable: false)
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {

        setNavBar(title: "ResetPasswordNavTitle".localized,
                  leftBarItem: .none,
                  rightBarItems: [.none])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Initialization Methods

    /// Text Field Settings
    func textFieldsSettings() {

        txtPassword.inputAccessoryView = vwNext
        txtConfirmPassword.inputAccessoryView = vwNext
    }

    // MARK: - Validate Fields

    /// Validate All Fields
    ///
    /// - Returns: Status
    func validateAllFields() -> (Bool, String?) {

        if txtPassword.text!.isEmpty {
            return (false, "Enter Password")
        } else if txtConfirmPassword.text!.isEmpty {
            return (false, "Enter Confirm Password")
        } else if txtPassword.text != txtConfirmPassword.text! {
            return (false, "Passwords are not same")
        } else if !AppUtility.isValidPassword(password: txtPassword.text!) {
            return (false, "PasswordRequirements".localized)
        } else if !AppUtility.isValidPassword(password: txtConfirmPassword.text!) {
            return (false, "PasswordRequirements".localized)
        }
        return (true, nil)
    }

    /// Validate Every Text Input
    ///
    /// - Parameter textField: Text Field
    func validateInput(textField: UITextField) {

        let strText = textField.text!.trimmingCharacters(in: .whitespacesAndNewlines)

        if textField == txtPassword {
            txtPassword.errorMessage = nil
            if strText.isEmpty {
                txtPassword.errorMessage = "Password is mandatory"
                return
            }
            if !AppUtility.isValidPassword(password: strText) {
                txtPassword.errorMessage = "Password doesn't matches the criteria"
                return
            }
        } else if textField == txtConfirmPassword {
            txtConfirmPassword.errorMessage = nil
            if strText.isEmpty {
                txtConfirmPassword.errorMessage = "Confirm Password is mandatory"
                return
            }
            if !AppUtility.isValidPassword(password: strText) {
                txtConfirmPassword.errorMessage = "Password doesn't matches the criteria"
                return
            }
        }
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

    // MARK: - Create User Model

    /// Create User Model
    ///
    /// - Returns: user model
    func createUserModel() -> UserModel? {

        let userModel = UserModel()
        guard let mobileNo = self.mobileNo else { return nil }
        userModel.mobileNumber = mobileNo
        userModel.password = txtPassword.text!
        return userModel
    }

    // MARK: - Web service Calls

    /// Reset Password Web service
    func resetPasswordWebService() {

        if !AppUtility.isNetworkAvailable() {
            AppUtility.showAlert("",
                                 message: "NetworkError".localized,
                                 delegate: self)
            return
        }

        guard let userModel = createUserModel() else { return }
        resetPassword(userModel,
                      withHandler: { (userDetails, isFromCache)  in

            // If App Token expire Then Call GetAppToken Service again to get token
            if let tokenExpire =  userDetails?.status,
                tokenExpire == AppConstants.tokenExpired {
                AppUtility.getAppDelegate()?.callAppTokenService(true,
                                                                 completionHandlerForTokenExpire: { (isSaved) in
                    if isSaved {
                        //After getting Token call the same service again
                        self.resetPasswordWebService()
                    }
                })
                return
            }

            guard let userInfo = userDetails else { return }

            if userInfo.status == AppConstants.successServiceCode {

                let signInVC = StoryboardScene.Main.instantiateSignInVC()
                signInVC.isFromResetPassword = true
                self.navigationController?.pushViewController(signInVC,
                                                              animated: true)

            } else {
                AppUtility.showAlert("",
                                     message: userInfo.message,
                                     delegate: nil)
            }
        }) { (error) in
            AppUtility.showAlert("",
                                 message: "Error",
                                 delegate: nil)
        }
    }

    // MARK: - IBActions
    @IBAction func btnResetPasswordAction(_ sender: Any) {

        self.view.endEditing(true)

        let tuple = validateAllFields()
        if tuple.0 == true {
            self.resetPasswordWebService()
        } else if let errMsg = tuple.1 {
            AppUtility.showAlert("",
                                 message: errMsg,
                                 delegate: nil)
        }
    }

    @IBAction func btnNextAction(_ sender: Any) {

        let tuple = validateAllFields()
        if tuple.0 == true {
            self.resetPasswordWebService()
        } else if let _ = tuple.1 {
            moveToNextTextField()
        }
    }
}

// MARK: - UITextField delagate methods
extension ResetPasswordVC: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {

        currentResponder = textField
    }

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {

        let strText = textField.text! as NSString

        let newText = strText.replacingCharacters(in: range,
                                                  with: string)

        if newText.length > AppConstants.maxPasswordLength {
            return false
        }

        if textField == txtPassword {

            txtPassword.text = newText
        } else if textField == txtConfirmPassword {

            txtConfirmPassword.text = newText
        }
        return false
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {

        validateInput(textField: textField)
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        let tag = textField.tag
        if let nextField = textField.superview?.viewWithTag(tag + 1)
            as? UITextField {

            nextField.becomeFirstResponder()
        } else {

            textField.resignFirstResponder()
        }
        return true
    }
}
