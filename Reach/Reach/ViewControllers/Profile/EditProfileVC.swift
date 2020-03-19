//
//  EditProfileVC.swift
//  Reach
//
//  Created by Aanchal Jain on 04/03/19.
//  Copyright © 2019 Netsolutions. All rights reserved.
//

import UIKit
import Kingfisher
import SCSDKLoginKit

class EditProfileVC: UIViewController, SignInAPI, ProfileAPI {

    // MARK: - Outlets
    @IBOutlet weak var imgVwProfile: UIImageView!

    @IBOutlet weak var btnAddProfile: UIButton!

    @IBOutlet weak var txtFullName: TextFontConstraint!

    @IBOutlet weak var txtUsername: TextFontConstraint!

    @IBOutlet weak var txtProvince: TextFontConstraint!

    @IBOutlet weak var txtCity: TextFontConstraint!

    @IBOutlet weak var lblAvailable: LabelFontConstraint!

    @IBOutlet weak var btnEdit: UIButton!

    @IBOutlet weak var btnCancel: UIButton!

    //Offline Views
    @IBOutlet var vwPicker: UIView!

    @IBOutlet var toolBar: UIToolbar!

    @IBOutlet weak var pickerView: UIPickerView!

    // MARK: - Variables
    var isNameAvailable = false

    var strTextField = ""
    var arrProfileStates = [ProvinceCityModel]()
    var arrProfileCities = [ProvinceCityModel]()

    var selectedStateRow = -1
    var selectedCityRow = -1
    var firstResponder = -1

    var stateCode: Int?
    var cityCode: Int?

    // handler of aws utility to show that images are uploaded
    var objectAWSProtocol: AWSProtocol?
    var objProfile: ProfileModel?

    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        // Do any additional setup after loading the view.
        super.viewDidLoad()

        setUI()
        textFieldsSettings()
        enableTextFields(isEnable: true)
        fillDetails()

        // Get all States using WebServices
        getAllStatesWebService()
    }

    override func viewWillAppear(_ animated: Bool) {

        setNavBarHide(hide: true)
    }

    // MARK: - Set up UI

    /// Set UI Elements
    func setUI() {

        imgVwProfile.layer.cornerRadius = imgVwProfile.frame.height / 2
        self.lblAvailable.isHidden = false
        self.lblAvailable.text = "Available"

    }

    /// Text Field Settings
    func textFieldsSettings() {

        txtProvince.inputView = vwPicker
        txtProvince.inputAccessoryView = UIView()
        txtCity.inputView = vwPicker
        txtCity.inputAccessoryView = UIView()
    }

    /// Enable Text Fields
    ///
    /// - Parameter isEnable: is Enable
    func enableTextFields(isEnable: Bool) {

        txtFullName.isUserInteractionEnabled = isEnable
        txtUsername.isUserInteractionEnabled = isEnable
        txtProvince.isUserInteractionEnabled = isEnable
        txtCity.isUserInteractionEnabled = isEnable
        btnAddProfile.isUserInteractionEnabled = isEnable
    }

    /// Fill Details
    func fillDetails() {

        if let profileDetails = objProfile,
            let province = profileDetails.state,
            let city = profileDetails.city {

            txtFullName.text = profileDetails.fullname ?? ""
            txtUsername.text = profileDetails.username ?? ""

            txtProvince.text = province.name ?? ""
            txtCity.text = city.name ?? ""

            stateCode = province.id
            cityCode = city.id

            if let profileImageStr = profileDetails.profileImage,
                let profileImageUrl = URL(string: profileImageStr) {
                imgVwProfile.kf.setImage(with: ImageResource(downloadURL: profileImageUrl),
                                         placeholder: UIImage(named: "avatarImage"),
                                         options: [KingfisherOptionsInfoItem.cacheMemoryOnly],
                                         progressBlock: nil,
                                         completionHandler: nil)
            } else {
                imgVwProfile.image = UIImage(named: "avatarImage")
            }
        }
    }

    /// Enable Next Button
    ///
    /// - Parameter shouldEnable: should enable
    func enableEditButton(shouldEnable: Bool) {

        if shouldEnable {

            btnEdit.isUserInteractionEnabled = true
            btnEdit.alpha = 1

        } else {

            btnEdit.isUserInteractionEnabled = false
            btnEdit.alpha = 0.5

        }
    }

    // MARK: - Validate Fields

    /// Validate All Fields
    ///
    /// - Returns: Status
    func validateAllFields() -> (Bool, String?) {

        if txtFullName.text!.isEmpty || txtUsername.text!.isEmpty
            || txtProvince.text!.isEmpty || txtCity.text!.isEmpty {

            return (false, "AllFieldsAreMandatory".localized)
        } else if txtUsername!.text!.count < AppConstants.minimumUsernameLength {

            return (false, "TooShortUsername".localized)
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
    }

    // MARK: - Create user model

    /// Create User Model
    ///
    /// - Returns: user model
    func createUserModel(imageURL: String) -> UserModel {

        let objUser = UserModel()
        objUser.fullname = txtFullName.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        objUser.username = txtUsername.text!.trimmingCharacters(in: .whitespacesAndNewlines)

        if selectedStateRow != -1 {
            if let selectedStateId = arrProfileStates[selectedStateRow].id {
                objUser.state = selectedStateId
            }
        } else {
            objUser.state = stateCode
        }

        if selectedCityRow != -1 {
            if let selectedCityId = arrProfileCities[selectedCityRow].id {
                objUser.city = selectedCityId
            }
        } else {
            objUser.city = cityCode
        }
        objUser.profileImage = imageURL
        return objUser
    }

    // MARK: - Upload Profile Image

    /// Upload Profile Image
    func uploadProfileImage() {

        if !AppUtility.isNetworkAvailable() {
            AppUtility.showAlert("",
                                 message: "NetworkError".localized,
                                 delegate: self)
            return
        }
        showLoader()

        let imageNameGuid = UUID().uuidString.lowercased()
        let folderName = "userprofiles/"
        let imageName = "\(imageNameGuid).jpeg"
        guard let image = self.imgVwProfile.image else { return }

        AWSProtocol.uploadImage(image: image,
                                imageName: imageName,
                                s3FolderName: folderName,
                                controller: self,
                                progressHandler: { (progress: Float) in

        }) { (isCompleted: Bool, error: Error?) in
            if isCompleted {

                let imageUrl = Configuration.s3Path() + folderName + imageName
                print("Uploaded image url: \(imageUrl)")
                self.callWebserviceToEditProfileData(imageURL: imageUrl)

            } else {
                self.dismissLoader()
                AppUtility.showAlert("",
                                     message: "Profile image could not be uploaded. Please try again!",
                                     delegate: nil)
            }
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

    // MARK: - IBActions

    @IBAction func btnAddProfileAction(_ sender: Any) {

        self.objectAWSProtocol = AWSProtocol(resizeHandler: { (isResized, resizedThumbImage) in
            // after resize set the image
            self.imgVwProfile.image = resizedThumbImage

        }, onComplete: { (_, _) in

        })

        self.objectAWSProtocol?.showActionSheetForImage(controller: self)
    }

    @IBAction func btnCancelToolbarAction(_ sender: Any) {

        self.view.endEditing(true)
    }

    @IBAction func btnDoneToolbarAction(_ sender: Any) {

        self.view.endEditing(true)
        if firstResponder == 0 {
            if self.selectedStateRow == -1 {
                return
            }
            txtProvince.text = arrProfileStates[self.selectedStateRow].name
            txtCity.text = ""
            validateInput(textField: txtProvince)
            self.getListOfAllCitiesWebService()
        } else if firstResponder == 1 {
            if self.selectedCityRow == -1 {
                return
            }
            txtCity.text = arrProfileCities[self.selectedCityRow].name
            validateInput(textField: txtCity)
        }

        let tuple = validateAllFields()
        enableEditButton(shouldEnable: tuple.0)
    }

    @IBAction func btnCancelAction(_ sender: Any) {

        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func btnPostEditAction(_ sender: Any) {

        let tuple = validateAllFields()
        if tuple.0 == true {
            //  call edit web service
            self.uploadProfileImage()
        } else if let errMsg = tuple.1 {
            AppUtility.showAlert("", message: errMsg,
                                 delegate: nil)
        }
    }

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
}
