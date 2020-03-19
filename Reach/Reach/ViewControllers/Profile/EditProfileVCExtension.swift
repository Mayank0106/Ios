//
//  EditProfileVCExtension.swift
//  Reach
//
//  Created by Aanchal Jain on 12/03/19.
//  Copyright © 2019 Netsolutions. All rights reserved.
//

import Foundation

// MARK: - Web service calls
extension EditProfileVC {

    /// Check if username available for user name
    ///
    /// - Parameter strTextInput: text
    func checkIfNameAvailableWebService(strTextInput: String) {

        if strTextInput.length < AppConstants.minimumUsernameLength {
            self.isNameAvailable = false
            AppUtility.showAlert("", message: "ShortDisplayName".localized, delegate: nil)
            return
        }
        if !AppUtility.isNetworkAvailable() {
            AppUtility.showAlert("", message: "NetworkError".localized, delegate: self)
            return
        }

        let userModel = UserModel()
        userModel.username = strTextInput

        checkIfUsernameAvailable(userModel,
                                 withHandler: { (userDetails, isFromCache)  in
                                    // If App Token expire Then Call GetAppToken Service again to get token
                                    if let tokenExpire =  userDetails?.status,
                                        tokenExpire == AppConstants.tokenExpired {

                                        AppUtility.getAppDelegate()?.callAppTokenService(true,
                                                                                         completionHandlerForTokenExpire: { (isSaved) in
                                                                                            if isSaved {
                                                                                                //After getting Token call the same service again
                                                                                                self.checkIfNameAvailableWebService(strTextInput: self.strTextField)
                                                                                            }
                                        })
                                        return
                                    }
                                    guard let userInfo = userDetails else { return }

                                    if self.strTextField.count < AppConstants.minimumUsernameLength {
                                        self.lblAvailable.isHidden = true
                                        return
                                    }
                                    if userInfo.status == AppConstants.successServiceCode {

                                        self.lblAvailable.isHidden = false
                                        self.lblAvailable.text = "AvailableText".localized
                                        self.isNameAvailable = true

                                        let tuple = self.validateAllFields()
                                        self.enableEditButton(shouldEnable: tuple.0)

                                    } else if userInfo.status == AppConstants.otherSuccess {

                                        self.lblAvailable.isHidden = false
                                        self.lblAvailable.text = "NotAvailableText".localized
                                        self.isNameAvailable = false

                                    } else {

                                        AppUtility.showAlert("", message: userInfo.message, delegate: nil)
                                    }
        }) { (error) in
            AppUtility.showAlert("", message: "Error", delegate: nil)
        }
    }

    /// Get listing of all province web service
    func getAllStatesWebService() {
        if !AppUtility.isNetworkAvailable() {
            AppUtility.showAlert("",
                                 message: "NetworkError".localized,
                                 delegate: self)
            return
        }
        self.listDownAllStates(withHandler: { (stateDetails, isFromCache)  in
            // If App Token expire Then Call GetAppToken Service again to get token
            if let tokenExpire =  stateDetails?.status,
                tokenExpire == AppConstants.tokenExpired {
                // acess token expire
                AppUtility.getAppDelegate()?.callAppTokenService(true,
                                                                 completionHandlerForTokenExpire: { (isSaved) in
                                                                    if isSaved {
                                                                        //After getting Token call the same service again
                                                                        self.getAllStatesWebService()
                                                                    }
                })
                return
            }
            guard let statesInfo = stateDetails else { return }

            if statesInfo.status == AppConstants.successServiceCode {
                guard let response = statesInfo.response else { return }
                self.arrProfileStates = response
                let index = self.arrProfileStates.index(where: { (state) -> Bool in
                    state.id == self.stateCode // test if this is the item you're looking for
                })

                if let indexExists = index {
                    self.selectedStateRow = indexExists
                    self.getListOfAllCitiesWebService()
                }
            } else {

                AppUtility.showAlert("",
                                     message: statesInfo.message,
                                     delegate: nil)
            }
        }) { (error) in
            AppUtility.showAlert("",
                                 message: "Error",
                                 delegate: nil)
        }
    }

    /// Get listing of all cities web service
    func getListOfAllCitiesWebService() {

        if !AppUtility.isNetworkAvailable() {
            AppUtility.showAlert("",
                                 message: "NetworkError".localized,
                                 delegate: self)
            return
        }

        guard let stateCode = arrProfileStates[self.selectedStateRow].stateCode else { return }

        listDownAllCities(stateCode, withHandler: { (cityDetails, isFromCache)  in
            // If App Token expire Then Call GetAppToken Service again to get token
            if let tokenExpire =  cityDetails?.status,
                tokenExpire == AppConstants.tokenExpired {
                // acess token expire
                AppUtility.getAppDelegate()?.callAppTokenService(true,
                                                                 completionHandlerForTokenExpire: { (isSaved) in
                                                                    if isSaved {
                                                                        //After getting Token, call the above method again
                                                                        self.getListOfAllCitiesWebService()
                                                                    }
                })
                return
            }
            guard let cityInfo = cityDetails else { return }

            if cityInfo.status == AppConstants.successServiceCode {

                guard let response = cityInfo.response else { return }
                self.arrProfileCities = response
                let index = self.arrProfileCities.index(where: { (city) -> Bool in
                    city.id == self.cityCode // test if this is the item you're looking for
                })

                if let indexExists = index {

                    self.selectedCityRow = indexExists
                }
            } else {

                AppUtility.showAlert("",
                                     message: cityInfo.message,
                                     delegate: nil)
            }
        }) { (error) in
            AppUtility.showAlert("",
                                 message: "Error",
                                 delegate: nil)
        }
    }

    /// Web service call to edit profile
    ///
    /// - Parameter imageURL: Image URL
    func callWebserviceToEditProfileData(imageURL: String) {

        if !AppUtility.isNetworkAvailable() {
            AppUtility.showAlert("", message: "NetworkError".localized, delegate: self)
            return
        }

        guard let data = KeychainWrapper.standard.object(forKey: AppConstants.userModelKeyChain),
            let userObj = data as? UserModel,
            let userId = userObj.id else {
                return
        }
        let userModel = createUserModel(imageURL: imageURL)
        editProfile(userID: userId,
                    body: userModel,
                    withHandler: { (userDetails, isFromCache)  in

                        guard let userInfo = userDetails else { return }

                        if userInfo.status == AppConstants.successServiceCode {

                            guard let response = userInfo.response else { return }
                            if let data = KeychainWrapper.standard.object(forKey: AppConstants.userModelKeyChain),
                                let userObj = data as? UserModel {

                                userObj.fullname = response.fullname
                                userObj.username = response.username
                                userObj.profileImage = response.profileImage
                                userObj.state = response.state
                                userObj.city = response.city

                                KeychainWrapper.standard.set(userObj,
                                                             forKey: AppConstants.userModelKeyChain)

                                ChatUser.updateUserValues(email: userObj.email!,
                                                          userName: userObj.username!,
                                                          userId: userObj.id!,
                                                          userImage: userObj.profileImage!) { (_, _)  in
                                }
                            }

                            self.navigationController?.popViewController(animated: true)

                        } else if userInfo.status == AppConstants.tokenExpired {

                            appDelegate.navigationToLoginIfAppTokenNotAvailableOrLogOut()
                        } else {
                            AppUtility.showAlert("", message: userInfo.message, delegate: nil)

                            self.navigationController?.popViewController(animated: true)
                        }
        }) { (error) in
            AppUtility.showAlert("",
                                 message: "Error",
                                 delegate: nil)
        }
    }
}

// MARK: - UITextField delagate methods
extension EditProfileVC: UITextFieldDelegate {

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {

        if textField == txtProvince && arrProfileStates.count > 0 {

            firstResponder = 0
            self.pickerView.reloadAllComponents()
            if self.selectedStateRow != -1 {
                self.pickerView.selectRow(self.selectedStateRow,
                                          inComponent: 0,
                                          animated: true)
            }

        } else if textField == txtCity {

            if txtProvince.text == "" {
                AppUtility.showAlert("",
                                     message: "SelectProvinceFirst".localized,
                                     delegate: nil)
            } else {
                firstResponder = 1
                self.pickerView.reloadAllComponents()
            }

            if self.selectedCityRow != -1 {
                self.pickerView.selectRow(self.selectedCityRow,
                                          inComponent: 0,
                                          animated: true)
            }
        } else {
            firstResponder = -1
        }

        return true
    }

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {

        let strText = textField.text! as NSString

        let newText = strText.replacingCharacters(in: range, with: string)

        if textField == txtUsername {

            strTextField = newText

            let userNameValidate = strTextField.length <= AppConstants.maxUsernameLength
                && (string.rangeOfCharacter(from: AppUtility.getAllowedCharacterSet() as CharacterSet) == nil)
            if userNameValidate == false {
                return false
            }

            // If text field contains more than 6 characters then check if name is available or not
            if strTextField.count >= AppConstants.minimumUsernameLength {

                checkIfNameAvailableWebService(strTextInput: strTextField)
                return true
            } else {

                self.lblAvailable.isHidden = true
                let tuple = validateAllFields()
                enableEditButton(shouldEnable: tuple.0)
                return true
            }
        } else if textField == txtFullName {

            if newText.length > AppConstants.maxFullNameLength {
                return false
            }
        }
        let tuple = validateAllFields()
        enableEditButton(shouldEnable: tuple.0)
        return true
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {

        validateInput(textField: textField)

        let tuple = validateAllFields()
        enableEditButton(shouldEnable: tuple.0)

        return true
    }
}

// MARK: - UIPicker Delegate & DataSource Methods
extension EditProfileVC: UIPickerViewDelegate, UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        if firstResponder == 0 {
            return arrProfileStates.count
        } else if firstResponder == 1 {
            return arrProfileCities.count
        }
        return 0
    }

    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {

        if firstResponder == 0 {
            return arrProfileStates[row].name
        } else if firstResponder == 1 {
            return arrProfileCities[row].name
        }
        return ""
    }

    func pickerView(_ pickerView: UIPickerView,
                    didSelectRow row: Int,
                    inComponent component: Int) {

        if firstResponder == 0 {

            self.selectedStateRow = row

        } else if firstResponder == 1 {

            self.selectedCityRow = row

        }
    }
}
