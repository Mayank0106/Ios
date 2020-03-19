//
//  SignUpVC.swift
//  Reach
//
//  Copyright © 2018 Netsolutions. All rights reserved.
//

import UIKit
import SCSDKLoginKit
import Kingfisher

class SignUpVC: UIViewController, SignInAPI, UIGestureRecognizerDelegate {

    // MARK: - Outlets
    @IBOutlet weak var imgVwProfile: UIImageView!

    @IBOutlet weak var btnAddProfile: UIButton!

    @IBOutlet weak var txtFullName: TextFontConstraint!

    @IBOutlet weak var txtUsername: TextFontConstraint!

    @IBOutlet weak var txtPassword: TextFontConstraint!

    @IBOutlet weak var txtEmail: TextFontConstraint!

    @IBOutlet weak var txtProvince: TextFontConstraint!

    @IBOutlet weak var txtCity: TextFontConstraint!

    @IBOutlet weak var txtGender: TextFontConstraint!

    @IBOutlet weak var lblAvailable: LabelFontConstraint!

    @IBOutlet weak var lblTermsAndConditions: LabelFontConstraint!

    @IBOutlet weak var constraintPasswordRequirementHt: NSLayoutConstraint!

    //Offline Views
    @IBOutlet var vwPicker: UIView!

    @IBOutlet var toolBar: UIToolbar!

    @IBOutlet weak var pickerView: UIPickerView!

    @IBOutlet var vwNext: UIView!

    @IBOutlet weak var btnNext: ButtonFontConstraint!

    // MARK: - Variables
    var isNameAvailable = false

    var strTextField = ""
    var arrStates = [ProvinceCityModel]()
    var arrCities = [ProvinceCityModel]()
    var arrGender = ["Male", "Female", "Other"]

    var selectedStateRow = 0
    var selectedCityRow = 0
    var selectedGender = 0
    var firstResponder = -1

    // handler of aws utility to show that images are uploaded
    var objectAWSProtocol: AWSProtocol?
    var isPhotoChange: Bool = false
    var isImageUpdate = false // to check whether image is added in  profile
    var isUploaded = false
    var selectedImage: String = ""
    var isFromSnapchat: Bool = false

    var currentResponder: Any?

    var objPageToOpen: PageToOpen?

    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {

        super.viewDidLoad()
        imgVwProfile.layer.cornerRadius = imgVwProfile.frame.height / 2
        lblTermsAndConditions.attributedText = AppUtility.setAttributedString(strValue: "Terms1".localized,
                                                                              typeToShow: "Terms2".localized,
                                                                              strValue1: "And".localized,
                                                                              typeToShow1: "PrivacyPolicy".localized)

        // Add Tap gesture on Terms Lable
        let tap = UITapGestureRecognizer(target: self, action: #selector(SignUpVC.tapLabel))
        lblTermsAndConditions.isUserInteractionEnabled = true
        lblTermsAndConditions.addGestureRecognizer(tap)

        self.lblAvailable.isHidden = true
        textFieldsSettings()
        getListOfAllStatesWebService()
        // Do any additional setup after loading the view.
    }

    @IBAction func tapLabel(gesture: UITapGestureRecognizer) {
        let text = (lblTermsAndConditions.text)!
        let termsRange = (text as NSString).range(of: "Terms2".localized)
        let privacyRange = (text as NSString).range(of: "PrivacyPolicy".localized)

        if gesture.didTapAttributedTextInLabel(label: lblTermsAndConditions, inRange: termsRange) {
            print("Tapped terms")
            objPageToOpen = .terms
            pushToWebPage()
        } else if gesture.didTapAttributedTextInLabel(label: lblTermsAndConditions, inRange: privacyRange) {
            print("Tapped privacy")
            objPageToOpen = .privacy
            pushToWebPage()
        } else {
            print("Tapped none")
        }
    }

    // Push to Terms & Conditions Page
    func pushToWebPage() {
        guard let webViewVC = tabBarStoryboard.instantiateViewController(withIdentifier: "WebViewVC")
            as? WebViewVC else { return }
        webViewVC.objPageToOpen = objPageToOpen
        self.navigationController?.pushViewController(webViewVC,
                                                      animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {

        setNavBar(title: "SignUpNavTitle".localized, leftBarItem: .backButton, rightBarItems: [.none])
        let strPasswordRequirements = "Password should have 6-15 alphanumeric & one special character."
        constraintPasswordRequirementHt.constant =
            strPasswordRequirements.height(withConstrainedWidth: appDelegate.window!.screen.bounds.width - 40,
                                                                                  font: UIFont(name: "Helvetica Bold", size: 11.0)!) + 5

        self.view.updateConstraints()
        self.view.layoutIfNeeded()
    }

    // MARK: - Initialization Methods

    /// Text Field Settings
    func textFieldsSettings() {

        txtFullName.inputAccessoryView = vwNext
        txtUsername.inputAccessoryView = vwNext
        txtPassword.inputAccessoryView = vwNext
        txtEmail.inputAccessoryView = vwNext

        txtProvince.inputView = vwPicker
        txtProvince.inputAccessoryView = vwNext

        txtCity.inputView = vwPicker
        txtCity.inputAccessoryView = vwNext

        txtGender.inputView = vwPicker
        txtGender.inputAccessoryView = vwNext

    }

    /// Move To Next Tsext Field
    func moveToNextTextField() {

        guard let currentTextField = currentResponder as? UITextField else { return }
        let tag = currentTextField.tag
        if let nextField = currentTextField.superview?.viewWithTag(tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            currentTextField.resignFirstResponder()
        }
    }

    // MARK: - Social Sign up Methods

    /// Fetch Snap Chat Info
    private func fetchSnapUserInfo() {

        let graphQLQuery = "{me{displayName,externalId, bitmoji{avatar}}}"
        SCSDKLoginClient
            .fetchUserData(
                withQuery: graphQLQuery,
                variables: nil,
                success: { userInfo in
                    if let userInfo = userInfo,
                        let data = try? JSONSerialization.data(withJSONObject: userInfo,
                                                               options: .prettyPrinted),
                        let objUserEntity = try? JSONDecoder().decode(UserEntity.self, from: data) {
                        DispatchQueue.main.async {

                            if let image = objUserEntity.avatar,
                                let profileImageUrl = URL(string: image) {

                                self.imgVwProfile.kf.setImage(with: ImageResource(downloadURL: profileImageUrl),
                                                              placeholder: UIImage(named: "avatarImage"),
                                                              options: [KingfisherOptionsInfoItem.cacheMemoryOnly],
                                                              progressBlock: nil,
                                                              completionHandler: nil)
                            }
                            self.txtFullName.text = objUserEntity.displayName

                        }
                    }
            }) { (error, isUserLoggedOut) in
                print(error?.localizedDescription ?? "")
        }
    }

    /// Log out from Snapchat
    func logoutSnapChat() {
        // Logout From Snap Chat
        SCSDKLoginClient.unlinkCurrentSession { (success: Bool) in
            // do something
        }
    }

    // MARK: - Validate Fields

    /// Validate All Fields
    ///
    /// - Returns: Status
    func validateAllFields() -> (Bool, String?) {
        if txtFullName.text!.isEmpty || txtUsername.text!.isEmpty || txtPassword.text!.isEmpty
            || txtEmail.text!.isEmpty || txtProvince.text!.isEmpty || txtCity.text!.isEmpty || txtGender.text!.isEmpty {
            return (false, "AllFieldsAreMandatory".localized)
        } else if txtUsername!.text!.count < AppConstants.minimumUsernameLength {
            return (false, "TooShortUsername".localized)
        } else if(self.lblAvailable.text == "NotAvailableText".localized) {
            return (false, "NotAvailableUsernameText".localized)
        } else if !AppUtility.isValidPassword(password: txtPassword.text!) {
            return (false, "PasswordRequirements".localized)
        } else if !AppUtility.validateEmail(emailStr: txtEmail.text!) {
            return (false, "InvalidEmailAddress".localized)
        } else if self.imgVwProfile?.image == nil {
            return (false, "PleaseChooseProfileImage".localized)
        }
        return (true, nil)
    }

    /// Validate Every Text Input
    ///
    /// - Parameter textField: Text Field
    func validateInput(textField: UITextField) {

        let strText = textField.text!.trimmingCharacters(in: .whitespacesAndNewlines)

        if textField == txtFullName && strText.isEmpty {
            txtFullName.errorMessage = "FullNameIsMandatory".localized
            return
        } else {
            txtFullName.errorMessage = nil
        }

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

        if textField == txtEmail {
            txtEmail.errorMessage = nil
            if strText.isEmpty {
                txtEmail.errorMessage = "EmailIsMandatory".localized
                return
            }
            if !AppUtility.validateEmail(emailStr: strText) {
                txtEmail.errorMessage = "InvalidEmailAddress".localized
                return
            }
        }
        validateInputContinued(textField: textField, strText: strText)
    }

    func validateInputContinued(textField: UITextField,
                                strText: String) {

        if textField == txtProvince && strText.isEmpty {
            txtProvince.errorMessage = "ProvinceIsMandatory".localized
            return
        } else {
            txtProvince.errorMessage = nil
        }

        if textField == txtCity && strText.isEmpty {
            txtCity.errorMessage = "CityIsMandatory".localized
            return
        } else {
            txtCity.errorMessage = nil
        }

        if textField == txtGender && strText.isEmpty {
            txtGender.errorMessage = "GenderIsMandatory".localized
            return
        } else {
            txtGender.errorMessage = nil
        }
    }

    // MARK: - Create user model

    /// Create User Model
    ///
    /// - Returns: user model
    func createUserModel() -> UserModel {
        let objUser = UserModel()
        objUser.fullname = txtFullName.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        objUser.username = txtUsername.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        objUser.password = txtPassword.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        objUser.email = txtEmail.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        objUser.state = arrStates[selectedStateRow].id!
        objUser.city = arrCities[selectedCityRow].id!
        objUser.gender = selectedGender + 1

        // Check Notification enabled or not
        let isRegisteredForRemoteNotifications = UIApplication.shared.isRegisteredForRemoteNotifications
        if isRegisteredForRemoteNotifications {
            objUser.isNotificationAllowed = true
        } else {
            objUser.isNotificationAllowed = false
        }
        let deviceInfo = AppUtility.createDeviceInfoObject()
        objUser.deviceId = deviceInfo.deviceId
        objUser.deviceToken = deviceInfo.deviceToken
        objUser.deviceType = deviceInfo.deviceType

        if let imageUser = self.imgVwProfile.image {
            objUser.tempProfileImage = imageUser
        }
        return objUser
    }

    // MARK: - Prepare For Segue
    override func prepare(for segue: UIStoryboardSegue,
                          sender: Any?) {
        if segue.identifier == StoryboardSegue.Main.toInputMobileNumberVC.rawValue {
            guard let verifyMobileNumberVC = segue.destination as? VerifyMobileNumberVC else { return }
            let userModel = createUserModel()
            verifyMobileNumberVC.userModel = userModel
        }
    }
}

extension SignUpVC {

    // MARK: - IBActions

    @IBAction func btnSignInViaSnapchatAction(_ sender: Any) {

        SCSDKLoginClient.login(from: self, completion: { success, error in

            if let error = error {
                print(error.localizedDescription)
                return
            }
            if success {
                self.fetchSnapUserInfo()
            }
        })
    }

    @IBAction func btnAddProfileAction(_ sender: Any) {
      
        isPhotoChange = true
        self.objectAWSProtocol = AWSProtocol(resizeHandler: { (isResized, resizedThumbImage) in
            self.isImageUpdate = isResized
            // after resize set the image
            self.imgVwProfile.image = resizedThumbImage

        }, onComplete: { (_, _) in

        })

        self.objectAWSProtocol?.showActionSheetForImage(controller: self)
    }
    
    @IBAction func btnSignUpAction(_ sender: Any) {

        self.view.endEditing(true)

        let tuple = validateAllFields()
        if tuple.0 == true {
            self.verifyEmailIDWebService()
        } else if let errMsg = tuple.1 {
            AppUtility.showAlert("", message: errMsg, delegate: nil)
        }
    }
    
    @IBAction func btnNextAction(_ sender: Any) {
        
        let tuple = validateAllFields()
        if tuple.0 == true {
            self.verifyEmailIDWebService()
        } else if let _ = tuple.1 {
            moveToNextTextField()
        }
    }
    
    @IBAction func btnCancelToolbarAction(_ sender: Any) {

        self.view.endEditing(true)
    }

    @IBAction func btnDoneToolbarAction(_ sender: Any) {

        self.view.endEditing(true)
        if firstResponder == 0 {

            txtProvince.text = arrStates[self.selectedStateRow].name
            txtCity.text = ""
            validateInput(textField: txtProvince)
            self.getListOfAllCitiesWebService()
        } else if firstResponder == 1 {

            txtCity.text = arrCities[self.selectedCityRow].name
            validateInput(textField: txtCity)
        } else if firstResponder == 2 {

            txtGender.text = arrGender[selectedGender]
            validateInput(textField: txtGender)
        }
    }
}
