//
//  OTPVC.swift
//  Reach
//
//  Copyright © 2018 Netsolutions. All rights reserved.
//

import UIKit

class OTPVC: UIViewController, NexmoAPI, SignInAPI {

    @IBOutlet weak var txtFieldOTP1: TextFontConstraint!

    @IBOutlet weak var txtFieldOTP2: TextFontConstraint!

    @IBOutlet weak var txtFieldOTP3: TextFontConstraint!

    @IBOutlet weak var txtFieldOTP4: TextFontConstraint!

    @IBOutlet weak var btnSendAgain: ButtonFontConstraint!

    //Offline Views

    @IBOutlet var vwNext: UIView!

    @IBOutlet weak var btnNext: ButtonFontConstraint!

    var requestedId = ""
    var objUserModel: UserModel?
    var isFromForgotPassword: Bool = false
    var mobileNumber: String? //in case from forgot password

    var timer = Timer()
    var timerValue = 300
    var timeCount = 300 // 5 minute

    override func viewDidLoad() {

        super.viewDidLoad()

        txtFieldOTP1.delegate = self
        txtFieldOTP2.delegate = self
        txtFieldOTP3.delegate = self
        txtFieldOTP4.delegate = self

        btnSendAgain.isEnabled = false
        btnSendAgain.alpha = 0.5
        timer = Timer.scheduledTimer(timeInterval: 1.00,
                                     target: self,
                                     selector: #selector(OTPVC.updateCounterTime),
                                     userInfo: nil,
                                     repeats: true)
        RunLoop.main.add(self.timer, forMode: RunLoopMode.commonModes)

        textFieldsSettings()
        enableNextButton(shouldEnable: false)

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {

        setNavBar(title: "Verification", leftBarItem: .backButton, rightBarItems: [.none])

    }

    override func viewDidAppear(_ animated: Bool) {

        txtFieldOTP1.becomeFirstResponder()
    }
    /// Clear all the fields on resend
    func clearAllOtpFields() {

        txtFieldOTP1.text = ""
        txtFieldOTP2.text = ""
        txtFieldOTP3.text = ""
        txtFieldOTP4.text = ""
    }

    // MARK: - Initialization Methods

    /// Text Field Settings
    func textFieldsSettings() {
        txtFieldOTP1.inputAccessoryView = vwNext
        txtFieldOTP2.inputAccessoryView = vwNext
        txtFieldOTP3.inputAccessoryView = vwNext
        txtFieldOTP4.inputAccessoryView = vwNext
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

    // MARK: - Validate Fields

    /// Validate All Fields
    ///
    /// - Returns: Status
    func validateAllFields() -> (Bool, String?) {

        if txtFieldOTP1.text!.isEmpty || txtFieldOTP2.text!.isEmpty
            || txtFieldOTP3.text!.isEmpty || txtFieldOTP4.text!.isEmpty {

            return (false, "AllFieldsAreMandatory".localized)
        }
        return (true, nil)
    }

    /// Update counter time
    @objc func updateCounterTime() {

        if self.timeCount > 0 {
            // If timer is greater than the 2 minute interval than reduce by 1 second
            print("Time Count", self.timeCount)
            self.btnSendAgain.isEnabled = false
            self.btnSendAgain.alpha = 0.5
            self.timeCount -= 1
        } else if self.timeCount == 0 {
            // in case of time completed the resend button will enable
            self.btnSendAgain.isEnabled = true
            self.btnSendAgain.alpha = 1
            print("Timer invalidate")
            self.timer.invalidate()
            self.timerValue = 300
            self.timeCount = 300
        }
    }

    func uploadProfileImage() {

        if !AppUtility.isNetworkAvailable() {
            AppUtility.showAlert("", message: "NetworkError".localized, delegate: self)
            return
        }

        guard let userModel = objUserModel, let profileImage = userModel.tempProfileImage else {
            return
        }

        showLoader()

        let imageNameGuid = UUID().uuidString.lowercased()
        let folderName = "userprofiles/"
        let imageName = "\(imageNameGuid).jpeg"
        AWSProtocol.uploadImage(image: profileImage,
                                imageName: imageName,
                                s3FolderName: folderName,
                                controller: self,
                                progressHandler: { (progress: Float) in

        }) { (isCompleted: Bool, error: Error?) in
            if isCompleted {
                self.objUserModel?.tempProfileImage = nil
                let imageUrl = Configuration.s3Path() + folderName + imageName
                print("Uploaded image url: \(imageUrl)")
                self.objUserModel?.profileImage = imageUrl
                self.registerWebService()
            } else {
                self.dismissLoader()
                AppUtility.showAlert("",
                                     message: "Profile image could not be uploaded. Please try again!",
                                     delegate: nil)
            }
        }
    }

    /// Verify OTP Web service
    func verifyOtpService() {

        if !AppUtility.isNetworkAvailable() {
            AppUtility.showAlert("", message: "NetworkError".localized, delegate: self)
            return
        }
        let strPin = txtFieldOTP1.text! + txtFieldOTP2.text! + txtFieldOTP3.text! + txtFieldOTP4.text!
        verifyOTP(requestedId: requestedId, pin: strPin, withHandler: { (eventId) in
            guard eventId != nil else {
                print("Invalid OTP")
                return
            }

            if self.isFromForgotPassword {
                self.performSegue(withIdentifier: StoryboardSegue.Main.toResetPasswordVC.rawValue, sender: self)

            } else {

                self.uploadProfileImage()
            }
        }) { (error) in
            AppUtility.showAlert("", message: "Error", delegate: nil)
        }
    }

    // MARK: Send OTP to Mobile
    func callSendOtpService() {

        if !AppUtility.isNetworkAvailable() {
            AppUtility.showAlert("", message: "NetworkError".localized, delegate: self)
            return
        }

        let mobileNumber: String?
        if isFromForgotPassword {
            mobileNumber = self.mobileNumber
        } else {
            guard let userModel = objUserModel else { return }
            mobileNumber = userModel.mobileNumber
        }
        guard let mobileNo = mobileNumber else { return }
        sendOTP(mobileNo, countryCode: AppConstants.countryCode, withHandler: { (requestId, status, _) in

            guard let requestID = requestId else { return }
            self.requestedId = requestID
            AppUtility.showAlert("", message: "Otp Sent Again", delegate: self)

        }) { (_) in
            AppUtility.showAlert("", message: "Unable to send code to this mobile number", delegate: nil)
        }
    }

    /// Web service call to register user
    func registerWebService() {

        if !AppUtility.isNetworkAvailable() {
            AppUtility.showAlert("", message: "NetworkError".localized, delegate: self)
            return
        }

        guard let userModel = objUserModel else { return }
        signUp(userModel, withHandler: { (userDetails, isFromCache)  in

            // If App Token expire Then Call GetAppToken Service again to get token
            if let tokenExpire =  userDetails?.status, tokenExpire == AppConstants.tokenExpired {
                AppUtility.getAppDelegate()?.callAppTokenService(true, completionHandlerForTokenExpire: { (isSaved) in
                    if isSaved {
                        //After getting Token call the same service again
                        self.registerWebService()
                    }
                })
                return
            }
            guard let userInfo = userDetails else { return }

            guard let response = userInfo.response else {

                AppUtility.showAlert("", message: userInfo.message, delegate: nil)
                return
            }
            if userInfo.status == AppConstants.successServiceCode {
                guard let accessToken = response.accessToken else { return }
                print("Access Token =====", accessToken)
                appDelegate.saveUserDetailsOnLogin(response: response)
                self.signupWithEmail(response: response)

            } else {
                AppUtility.showAlert("", message: userInfo.message, delegate: nil)
            }
        }) { (error) in
            AppUtility.showAlert("", message: "Error", delegate: nil)
        }
    }

    // MARK: Firebase SignUp
    func signupWithEmail(response: UserModel) {

        guard let userModel = objUserModel else { return }
        ChatUser.signupWithEmail(email: response.email!,
                                 password: userModel.password!,
                                 userName: response.username!,
                                 userId: response.id!,
                                 userImage: response.profileImage!,
                                 completion: { (success, message)  in
            if success {
                print("true")
            } else {
                print("false")
            }
        })
    }

    // MARK: - IBActions
    @IBAction func btnResendOTPAction(_ sender: Any) {
        if AppUtility.isNetworkAvailable() {

            clearAllOtpFields()
            txtFieldOTP1.becomeFirstResponder()
            callSendOtpService()
            print("Resend Called Again")
            self.timeCount = self.timerValue
            self.timer = Timer.scheduledTimer(timeInterval: 1.00,
                                              target: self,
                                              selector: #selector(OTPVC.updateCounterTime),
                                              userInfo: nil,
                                              repeats: true)
            RunLoop.main.add(self.timer, forMode: RunLoopMode.commonModes)
        } else {
            AppUtility.showAlert("", message: "NetworkError".localized, delegate: self)
            return
        }
    }

    // MARK: - IBActions

    @IBAction func btnNextAction(_ sender: Any) {

        let tuple = validateAllFields()
        if tuple.0 == true {
            self.verifyOtpService()
        } else if let errMsg = tuple.1 {
            AppUtility.showAlert("", message: errMsg, delegate: nil)
        }
    }

    @IBAction func btnNextOfflineAction(_ sender: Any) {

        self.view.endEditing(true)

        let tuple = validateAllFields()
        if tuple.0 == true {
            self.verifyOtpService()
        } else if let errMsg = tuple.1 {
            AppUtility.showAlert("", message: errMsg, delegate: nil)
        }
    }

    // MARK: - Prepare For Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == StoryboardSegue.Main.toResetPasswordVC.rawValue {

            guard let resetVC = segue.destination as? ResetPasswordVC else { return }
            resetVC.mobileNo = self.mobileNumber
        }
    }
}

extension OTPVC: UITextFieldDelegate {

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {

        // Make first responder next text field if length is greater than 0

        print(txtFieldOTP1.text! + txtFieldOTP2.text! + txtFieldOTP3.text! + txtFieldOTP4.text!)
        if string == "" {
            textField.text! = ""
            let tuple = validateAllFields()
            enableNextButton(shouldEnable: tuple.0)
            return true
        }

        if textField.text!.count >= 1 && textField.text!.length > 0 {

            let nextTag = textField.tag + 1

            let nextResponder = textField.superview?.viewWithTag(nextTag)

            if let textView = nextResponder as? UITextField {
                textView.text = string
                textView.becomeFirstResponder()
                let tuple = validateAllFields()
                enableNextButton(shouldEnable: tuple.0)
            }

            return false
        } else {
            textField.text = string
            let tuple = validateAllFields()
            enableNextButton(shouldEnable: tuple.0)
        }

        return false
    }

}
