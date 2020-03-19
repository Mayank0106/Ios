//
//  EditEventVCExtension.swift
//  Reach
//
//  Created by Aanchal Jain on 29/03/19.
//  Copyright © 2019 Netsolutions. All rights reserved.
//

import UIKit

// MARK: - UIPickerView Delegate and DataSource methods
extension EditEventVC: UIPickerViewDelegate, UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {

        return 1
    }

    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {

        return arrHours.count
    }

    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {

        return arrHours[row]
    }

    func pickerView(_ pickerView: UIPickerView,
                    didSelectRow row: Int,
                    inComponent component: Int) {

        self.selectedRow = row
    }
}

// MARK: - UITextView delagate methods
extension EditEventVC: UITextViewDelegate {

    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView == txtVwReleaseTime {
            firstResponder = 1
        }
        return true
    }

    func textView(_ textView: UITextView,
                  shouldChangeTextIn range: NSRange,
                  replacementText text: String) -> Bool {
        let strText = textView.text! as NSString
        let newText = strText.replacingCharacters(in: range, with: text)
        if textView == txtVwAddress || textView == txtVwExtraDetails {
            if newText.count > maxAddressLength || text == "\n" {
                textView.resignFirstResponder()
                return false
            }
        }
        return true
    }
}

// MARK: - UITextField delegate methods
extension EditEventVC: UITextFieldDelegate {

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {

        let strText = textField.text! as NSString

        let newText = strText.replacingCharacters(in: range,
                                                  with: string)

        if textField == txtPartyName {

            if newText.length > maxPartyNameLength {
                return false
            }
        }

        if textField == txtFieldStreet1 || textField == txtFieldStreet2 {

            if newText.count >= maxStreetLength {
                return false
            }
        }
        textField.text = newText
        return false
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == txtFieldTime {
            firstResponder = 0
        }
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
// MARK: - SelectedFriendsList delegate methods
extension EditEventVC: SelectedFriendsList {

    func sendBackSelectedFriendList(arrSelectedFriends: [FriendModel]) {
        self.selectedFriends = arrSelectedFriends
        constraintVwInviteFriends.constant = openSizeFriendListField
        self.setUpFriendsList()
    }
}

extension EditEventVC {
    // MARK: - IBActions

    @IBAction func btnInviteFriendsAction(_ sender: Any) {

        self.view.endEditing(true)
        guard let inviteFriendsVC = tabBarStoryboard.instantiateViewController(withIdentifier: "InviteFriendsVC")
            as? InviteFriendsVC else { return }

        inviteFriendsVC.delegate = self
        inviteFriendsVC.arrSelectedFriendList = self.selectedFriends
        inviteFriendsVC.eventID = eventID
        self.present(inviteFriendsVC, animated: true, completion: nil)

    }

    @IBAction func btnSelectBannerAction(_ sender: Any) {
        lblBannerSmall.isHidden = false
        lblBannerBig.isHidden = true
        self.objectAWSProtocol = AWSProtocol(resizeHandler: { (_, resizedThumbImage) in
            self.imgVwBanner.image = resizedThumbImage
            self.imgOverlay.isHidden = false
            self.isImageChange = true
        }, onComplete: { (_, _) in
            print("Download complete")
        })
        self.objectAWSProtocol?.showActionSheetForImage(controller: self)
    }

    @IBAction func btnBackArrowAction(_ sender: Any) {

        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func btnDoneAction(_ sender: Any) {

        self.view.endEditing(true)
        let tuple = validateAllFields()
        if tuple.0 == true {
            //  call edit web service
            if self.isImageChange {
                self.uploadBannerImage(isDraft: false)
            } else {
                guard let event = eventDetail else { return }
                if let bannerImage = event.bannerImage {
                    self.editPartyEventWebService(bannerImageURL: bannerImage)
                }
            }
        } else if let errMsg = tuple.1 {
            AppUtility.showAlert("", message: errMsg,
                                 delegate: nil)
        }
    }

    @objc func dateChanged(_ sender: UIDatePicker) {

        self.selectedDate = sender.date
    }

    @IBAction func btnCancelToolbarAction(_ sender: Any) {

        self.view.endEditing(true)

    }

    @IBAction func btnDoneToolbarAction(_ sender: Any) {

        if firstResponder == 0 { // Selection is made from Date Picker

            let selectedDate = self.selectedDate ?? datePickerDate
            guard let date = selectedDate else { return }
            let components = Calendar.current.dateComponents([.year, .month, .day],
                                                             from: date)
            if let day = components.day, let month = components.month, let year = components.year {

                txtFieldTime.text =
                "\(String(format: "%02d", day))-\(String(format: "%02d", month))-\(String(format: "%02d", year))"
            }

            let formatter = DateFormatter()
            formatter.dateFormat = "hh:mm a"
            let strHourMinute = formatter.string(from: date)

            txtFieldTime.text = txtFieldTime.text! + " " + strHourMinute

        } else if firstResponder == 1 { // Selection is made from Picker

            if let selectedRow = self.selectedRow {
                 txtVwReleaseTime.text = arrHours[selectedRow]
            } else {
                self.selectedRow = 0
                txtVwReleaseTime.text = arrHours[0]
            }
        }
        self.view.endEditing(true)
    }

    @IBAction func btnMainIntersectionAction(_ sender: Any) {

        self.view.endEditing(true)
        self.btnMainIntersection.isUserInteractionEnabled = false

        UIView.animate(withDuration: 0.5,
                       delay: 0.1,
                       options: UIViewAnimationOptions.curveEaseIn,
                       animations: { () -> Void in

                        self.txtFieldStreet1.backgroundColor = #colorLiteral(red: 0.1215686275, green: 0.1215686275, blue: 0.1215686275, alpha: 1)
                        self.txtFieldStreet2.backgroundColor = #colorLiteral(red: 0.1215686275, green: 0.1215686275, blue: 0.1215686275, alpha: 1)

                        self.txtFieldStreet1.isHidden = false
                        self.txtFieldStreet2.isHidden = false

                        self.constraintTxtFieldStreet1Ht.constant = 50
                        self.constraintTxtFieldStreet2Ht.constant = 50

                        self.view.updateConstraints()
                        self.view.layoutIfNeeded()

        }, completion: { (finished) -> Void in
            // ....
        })
    }

    @IBAction func btnCloseEventAction(_ sender: Any) {

        self.eventType = 2
        guard let event = eventDetail, let eventID = event.id else { return }
        deleteEventInvitationsWebService(eventID: eventID) { (_) in
            self.setEventType(eventType: 2)
        }
    }

    @IBAction func btnOpenEventAction(_ sender: Any) {

        self.eventType = 1
        guard let event = eventDetail, let eventID = event.id else { return }
        deleteEventInvitationsWebService(eventID: eventID) { (_) in
            self.setEventType(eventType: 1)
        }
    }

    @IBAction func btnBackAction(_ sender: Any) {

        self.navigationController?.popViewController(animated: true)
    }
}

extension EditEventVC {

    /// Calculate Address Time
    ///
    /// - Parameter rowNo: Row No
    /// - Returns: Hours
    func calculateAddressTime(rowNo: Int) -> Int {

        var addressTime = 1
        switch rowNo {
        case 0:
            addressTime = 0
        case 1:
            addressTime = 1
        case 2:
            addressTime = 2
        case 3:
            addressTime = 3
        case 4:
            addressTime = 5
        case 5:
            addressTime = 10
        case 6:
            addressTime = 24
        case 7:
            addressTime = 48
        case 8:
            addressTime = 72
        default:
            addressTime = 168
        }
        return addressTime
    }

    /// Calculate Address Time
    ///
    /// - Parameter rowNo: Row No
    /// - Returns: Hours
    func showAddressTimeInHoursDays(addressTime: Int) -> String {

        var strAddressTime = ""
        switch addressTime {
        case 0:
            strAddressTime = "0 hours"
        case 1:
            strAddressTime = "1 hours"
        case 2:
            strAddressTime = "2 hours"
        case 3:
            strAddressTime = "3 hours"
        case 5:
            strAddressTime = "5 hours"
        case 10:
            strAddressTime = "10 hours"
        case 24:
            strAddressTime = "1 Day"
        case 48:
            strAddressTime = "2 Days"
        case 72:
            strAddressTime = "3 Days"
        default:
            strAddressTime = "7 Days"
        }
        return strAddressTime
    }
}
