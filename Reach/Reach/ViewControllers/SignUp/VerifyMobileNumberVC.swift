//
//  VerifyMobileNumberVC.swift
//  Reach
//
//  Copyright © 2019 Netsolutions. All rights reserved.
//

import UIKit

class VerifyMobileNumberVC: UIViewController, SignInAPI, NexmoAPI {

    @IBOutlet weak var txtMobileNumber: TextFontConstraint!

    //Offline Views

    @IBOutlet var vwNext: UIView!

    @IBOutlet weak var btnNext: ButtonFontConstraint!

    // MARK: - Variables
    var currentString = ""

    var requestId = ""

    var userModel: UserModel?

    override func viewDidLoad() {

        super.viewDidLoad()
        textFieldsSettings()
        enableNextButton(shouldEnable: false)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {

        setNavBar(title: "PhoneNumber".localized, leftBarItem: .backButton, rightBarItems: [.none])
    }

    // MARK: - Initialization Methods

    /// Text Field Settings
    func textFieldsSettings() {

        txtMobileNumber.inputAccessoryView = vwNext
    }

    /// Enable Next Button
    ///
    /// - Parameter shouldEnable: should enable
    func enableNextButton(shouldEnable: Bool) {
        if shouldEnable {
            btnNext.isEnabled = true
            btnNext.backgroundColor = #colorLiteral(red: 0.9019607843, green: 0.1960784314, blue: 0.1960784314, alpha: 1)
            btnNext.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
        } else {
            btnNext.isEnabled = false
            btnNext.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            btnNext.setTitleColor(#colorLiteral(red: 0.7764705882, green: 0.7764705882, blue: 0.7764705882, alpha: 1), for: .normal)
        }
    }

    /// Validate Mobile Web service
    func validateMobileNoWebService() {

        if !AppUtility.isNetworkAvailable() {
            AppUtility.showAlert("", message: "NetworkError".localized, delegate: self)
            return
        }

        let userModel = UserModel()
        userModel.mobileNumber = currentString
        validateMobileNumber(userModel, withHandler: { (userDetails, isFromCache)  in

            // If App Token expire Then Call GetAppToken Service again to get token
            if let tokenExpire =  userDetails?.status, tokenExpire == AppConstants.tokenExpired {
                // acess token expire
                AppUtility.getAppDelegate()?.callAppTokenService(true, completionHandlerForTokenExpire: { (isSaved) in
                    if isSaved {
                        //After getting Token call the same service again
                        self.validateMobileNoWebService()
                    }
                })
                return
            }

            guard let userInfo = userDetails else { return }

            if userInfo.status == AppConstants.successServiceCode {

                self.callSendOtpService()
            } else {
                AppUtility.showAlert("", message: userInfo.message, delegate: nil)
            }
        }) { (error) in
            AppUtility.showAlert("", message: "Error", delegate: nil)
        }
    }

    // MARK: - Validate Fields

    /// Validate All Fields
    ///
    /// - Returns: Status
    func validateAllFields() -> (Bool, String?) {
        if txtMobileNumber.text!.isEmpty {
            return (false, "EnterValidMobileNumber".localized)
        }
        return (true, nil)
    }

    /// Validate Every Text Input
    ///
    /// - Parameter textField: Text Field
    func validateInput(textField: UITextField) {

        let strText = textField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if textField == txtMobileNumber && strText.isEmpty {
            txtMobileNumber.errorMessage = "EnterValidMobileNumber".localized
            return
        }
    }

    // MARK: Send OTP to Mobile
    func callSendOtpService() {

        if !AppUtility.isNetworkAvailable() {
            AppUtility.showAlert("", message: "NetworkError".localized, delegate: self)
            return
        }
        sendOTP(currentString, countryCode: AppConstants.countryCode, withHandler: { (requestId, _, _)  in

            guard let requestID = requestId else { return }
            self.requestId = requestID
            self.performSegue(withIdentifier: StoryboardSegue.Main.toEnterOTPVC.rawValue, sender: self)
        }) { (_) in
            AppUtility.showAlert("", message: "UnableToSendCode".localized, delegate: nil)
        }
    }

    // MARK: - IBActions
    @IBAction func btnSendSMSAction(_ sender: Any) {

        self.view.endEditing(true)

        let tuple = validateAllFields()
        if tuple.0 == true {
            self.validateMobileNoWebService()
        } else if let errMsg = tuple.1 {
            AppUtility.showAlert("", message: errMsg, delegate: nil)
        }
    }

    @IBAction func btnNextAction(_ sender: Any) {

        self.view.endEditing(true)

        let tuple = validateAllFields()
        if tuple.0 == true {
            self.validateMobileNoWebService()
        } else if let errMsg = tuple.1 {
            AppUtility.showAlert("", message: errMsg, delegate: nil)
        }
    }

    // MARK: - Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == StoryboardSegue.Main.toEnterOTPVC.rawValue {
            guard let otpVC = segue.destination as? OTPVC else {
                return
            }
            otpVC.requestedId = self.requestId
            guard let objUserModel = userModel else { return }
            objUserModel.mobileNumber = currentString
            otpVC.objUserModel = objUserModel
        }
    }
}

// MARK: - UITextfield delegate methods
extension VerifyMobileNumberVC: UITextFieldDelegate {

    // Allowing users to enter correct mobile number and then formatting it
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {

        if textField == txtMobileNumber {

            switch string {
            case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9":
                if currentString.length >= AppConstants.mobileNoLength {
                    return false
                }
                currentString += string

                txtMobileNumber.text = AppUtility.foramtingTheMobile(currentString)
            default:
                var currentStringArray = currentString
                if string == "" && currentStringArray.count != 0 {
                    currentStringArray.removeLast()
                    currentString = ""
                    for character in currentStringArray {
                        currentString += String(character)
                    }
                }
            }
            txtMobileNumber.text = AppUtility.foramtingTheMobile(currentString)
            if currentString.count == 10 {
                self.enableNextButton(shouldEnable: true)
            } else {
                self.enableNextButton(shouldEnable: false)
            }
            return false
        }
        return true
    }
}
