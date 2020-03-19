//
//  SignUpVCExtension.swift
//  Reach
//
//  Created by Aanchal Jain on 12/03/19.
//  Copyright © 2019 Netsolutions. All rights reserved.
//

import Foundation

// MARK: - UITextField delagate methods
extension SignUpVC: UITextFieldDelegate {

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {

        currentResponder = textField
        if textField == txtProvince && arrStates.count > 0 {

            firstResponder = 0
            self.pickerView.reloadAllComponents()
        } else if textField == txtCity {

            if txtProvince.text == "" {
                AppUtility.showAlert("",
                                     message: "SelectProvinceFirst".localized,
                                     delegate: nil)
            } else {
                firstResponder = 1
                self.pickerView.reloadAllComponents()
            }

        } else if textField == txtGender {

            firstResponder = 2
            self.pickerView.reloadAllComponents()
        } else {
            firstResponder = -1
        }

        return true
    }

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {

        let strText = textField.text! as NSString

        let newText = strText.replacingCharacters(in: range,
                                                  with: string)

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
                return true
            }
        } else if textField == txtFullName {

            if newText.length > AppConstants.maxFullNameLength {
                return false
            }
        } else if textField == txtEmail {

            if newText.length > AppConstants.maxEmailLength {
 
                return false
            }
        } else if textField == txtPassword {

            if newText.length > AppConstants.maxPasswordLength {
                return false
            }
        }
        return true
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {

        validateInput(textField: textField)

//        let tuple = validateAllFields()
//        enableNextButton(shouldEnable: tuple.0)

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

// MARK: - Picker
extension SignUpVC: UIPickerViewDelegate, UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {

        return 1
    }

    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {

        if firstResponder == 0 {
            return arrStates.count
        } else if firstResponder == 1 {
            return arrCities.count
        } else if firstResponder == 2 {
            return arrGender.count
        }
        return 0
    }

    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {

        if firstResponder == 0 {
            return arrStates[row].name
        } else if firstResponder == 1 {
            return arrCities[row].name
        } else if firstResponder == 2 {
            return arrGender[row]
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

        } else if firstResponder == 2 {

            self.selectedGender = row

        }
    }
}

extension SignUpVC {

    // MARK: - Web service calls

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
                                    if let tokenExpire =  userDetails?.status, tokenExpire == AppConstants.tokenExpired {
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
    func getListOfAllStatesWebService() {

        if !AppUtility.isNetworkAvailable() {
            AppUtility.showAlert("",
                                 message: "NetworkError".localized,
                                 delegate: self)
            return
        }
        listDownAllStates(withHandler: { (stateDetails, isFromCache)  in
            // If App Token expire Then Call GetAppToken Service again to get token
            if let tokenExpire =  stateDetails?.status,
                tokenExpire == AppConstants.tokenExpired {
                // acess token expire
                AppUtility.getAppDelegate()?.callAppTokenService(true,
                                                                 completionHandlerForTokenExpire: { (isSaved) in
                                                                    if isSaved {
                                                                        //After getting Token call the same service again
                                                                        self.getListOfAllStatesWebService()
                                                                    }
                })
                return
            }
            guard let statesInfo = stateDetails else { return }

            if statesInfo.status == AppConstants.successServiceCode {

                guard let response = statesInfo.response else { return }
                self.arrStates = response

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

        guard let stateCode = arrStates[self.selectedStateRow].stateCode else { return }

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
                self.arrCities = response

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

    /// Verify Email ID web service
    func verifyEmailIDWebService() {

        if !AppUtility.isNetworkAvailable() {
            AppUtility.showAlert("",
                                 message: "NetworkError".localized,
                                 delegate: self)
            return
        }

        let userModel = UserModel()
        userModel.email = txtEmail.text!.trimmingCharacters(in: .whitespacesAndNewlines)

        verifyEmailID(userModel, withHandler: { (userDetails, isFromCache)  in

            if let tokenExpire =  userDetails?.status,
                tokenExpire == AppConstants.tokenExpired {
                // acess token expire
                AppUtility.getAppDelegate()?.callAppTokenService(true,
                                                                 completionHandlerForTokenExpire: { (isSaved) in
                                                                    if isSaved {
                                                                        self.verifyEmailIDWebService()
                                                                    }
                })
                return
            }
            guard let userInfo = userDetails else { return }

            if userInfo.status == AppConstants.successServiceCode {

                self.performSegue(withIdentifier: StoryboardSegue.Main.toInputMobileNumberVC.rawValue,
                                  sender: self)
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
}
