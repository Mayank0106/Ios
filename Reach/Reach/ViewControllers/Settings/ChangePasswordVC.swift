//
//  ChangePasswordVC.swift
//  Reach
//
//  Copyright © 2019 Netsolutions. All rights reserved.
//

import UIKit

class ChangePasswordVC: UIViewController, SignInAPI {

    // MARK: - IBOutlets
    @IBOutlet weak var txtOldPassword: TextFontConstraint!

    @IBOutlet weak var txtNewPassword: TextFontConstraint!

    @IBOutlet weak var txtNewPasswordAgain: TextFontConstraint!

    //Offline Views

    @IBOutlet var vwNext: UIView!

    @IBOutlet weak var btnNext: ButtonFontConstraint!

    var currentResponder: UITextField?

    // MARK: - View controller life cycle
    override func viewDidLoad() {

        super.viewDidLoad()
        textFieldsSettings()

        // Do any additional setup after loading the view.
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(gesture:)))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
    }
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                _ = self.navigationController?.popViewController(animated: true)
            default:
                break
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {

        setNavBar(title: "PasswordNavTitle".localized,
                  leftBarItem: .backButton,
                  rightBarItems: [.none])

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "BackNavButton".localized,
                                                                style: .plain, target: self,
                                                                action: #selector(backAction(sender:)))
        self.navigationItem.leftBarButtonItem?
            .setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "Helvetica Bold", size: 16)!],
                                                                      for: .normal)
    }

    // MARK: - Initialization Methods

    /// Text Field Settings
    func textFieldsSettings() {

        txtOldPassword.inputAccessoryView = vwNext
        txtNewPassword.inputAccessoryView = vwNext
        txtNewPasswordAgain.inputAccessoryView = vwNext
    }

    // MARK: - Validate Fields

    /// Validate All Fields
    ///
    /// - Returns: Status
    func validateAllFields() -> (Bool, String?) {

        if txtOldPassword.text!.isEmpty || txtNewPassword.text!.isEmpty
            || txtNewPasswordAgain.text!.isEmpty {
            return (false, "AllFieldsAreMandatory".localized)
        } else if txtNewPassword.text != txtNewPasswordAgain.text! {
            return (false, "Passwords are not same")
        } else if !AppUtility.isValidPassword(password: txtNewPassword.text!) {
            return (false, "PasswordRequirements".localized)
        } else if !AppUtility.isValidPassword(password: txtNewPasswordAgain.text!) {
            return (false, "PasswordRequirements".localized)
        }
        return (true, nil)
    }

    /// Validate Every Text Input
    ///
    /// - Parameter textField: Text Field
    func validateInput(textField: UITextField) {

        let strText = textField.text!.trimmingCharacters(in: .whitespacesAndNewlines)

        if textField == txtOldPassword {

            txtOldPassword.errorMessage = nil
            if strText.isEmpty {
                txtOldPassword.errorMessage = "Old Password is mandatory"
                return
            }
            if !AppUtility.isValidPassword(password: strText) {
                txtOldPassword.errorMessage = "PasswordShouldHaveAlphanumericSpecialCharacter".localized
                return
            }
        } else if textField == txtNewPassword {

            txtNewPassword.errorMessage = nil
            if strText.isEmpty {
                txtNewPassword.errorMessage = "New Password is mandatory"
                return
            }
            if !AppUtility.isValidPassword(password: strText) {
                txtNewPassword.errorMessage = "Password doesn't matches the criteria"
                return
            }
        } else if textField == txtNewPasswordAgain {

            txtNewPasswordAgain.errorMessage = nil
            if strText.isEmpty {
                txtNewPasswordAgain.errorMessage = "Confirm Password is mandatory"
                return
            }
            if !AppUtility.isValidPassword(password: strText) {
                txtNewPasswordAgain.errorMessage = "Password doesn't matches the criteria"
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
        userModel.oldPassword = txtOldPassword.text!
        userModel.newPassword = txtNewPassword.text!
        return userModel
    }

    // MARK: - Web service Calls

    /// Change Password Web service
    func changePasswordWebService() {

        if !AppUtility.isNetworkAvailable() {
            AppUtility.showAlert("", message: "NetworkError".localized, delegate: self)
            return
        }

        guard let userModel = createUserModel() else { return }
        changePassword(userModel,
                       withHandler: { (userDetails, isFromCache)  in

            guard let userInfo = userDetails else { return }

            if userInfo.status == AppConstants.successServiceCode {

                let alertController = UIAlertController(title: "",
                                                        message: "PasswordChanged".localized,
                                                        preferredStyle: .alert)

                // Create the actions
                let okAction = UIAlertAction(title: "OK".localized,
                                             style: UIAlertActionStyle.default) {
                    UIAlertAction in
                    self.navigationController?.popViewController(animated: true)
                }

                // Add the actions
                alertController.addAction(okAction)

                // Present the controller
                self.present(alertController,
                             animated: true,
                             completion: nil)

            } else if userInfo.status == AppConstants.tokenExpired {

                appDelegate.navigationToLoginIfAppTokenNotAvailableOrLogOut()
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
    @objc override func backAction(sender: UIButton) {

        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func btnNextAction(_ sender: Any) {

        let tuple = validateAllFields()
        if tuple.0 == true {
            self.changePasswordWebService()
        } else if let _ = tuple.1 {
            moveToNextTextField()
        }
    }

    @IBAction func btnSaveAction(_ sender: Any) {

        self.view.endEditing(true)

        let tuple = validateAllFields()
        if tuple.0 == true {
            self.changePasswordWebService()
        } else if let errMsg = tuple.1 {
            AppUtility.showAlert("",
                                 message: errMsg,
                                 delegate: nil)
        }
    }
}

// MARK: - UITextField delagate methods
extension ChangePasswordVC: UITextFieldDelegate {

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {

        currentResponder = textField
        return true
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

        if textField == txtOldPassword {
            txtOldPassword.text = newText
        } else if textField == txtNewPassword {
            txtNewPassword.text = newText
        } else if textField == txtNewPasswordAgain {
            txtNewPasswordAgain.text = newText
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
