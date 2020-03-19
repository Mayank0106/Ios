//
//  CreatePartyDetailVCExtension.swift
//  Reach
//
//  Created by Aanchal Jain on 12/03/19.
//  Copyright © 2019 Netsolutions. All rights reserved.
//

import Foundation

// MARK: - UITextField delagate methods
extension CreatePartyDetailVC: UITextFieldDelegate {

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {

        let strText = textField.text! as NSString

        let newText = strText.replacingCharacters(in: range, with: string)

        if textField == txtFieldStreet1 || textField == txtFieldStreet2 {

            if newText.count >= maxStreetLength {

                return false
            }
        }
        textField.text = newText
//        let tuple = validateAllFields()
//        enableNextButton(shouldEnable: tuple.0)
        return false
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {

        currentResponder = textField
        if textField == txtFieldTime {
            firstResponder = 0

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
        if let nextField = textField.superview?.viewWithTag(tag + 1)
            as? UITextField {

            nextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
}

// MARK: - UITextView delagate methods
extension CreatePartyDetailVC: UITextViewDelegate {

    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {

        currentResponder = textView
        if textView == txtVwReleaseTime {
            firstResponder = 1
        }

        return true
    }

    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {

        validateInput(textView: textView)

//        let tuple = validateAllFields()
//        enableNextButton(shouldEnable: tuple.0)

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
//        let tuple = validateAllFields()
//        enableNextButton(shouldEnable: tuple.0)
        return true
    }
}

// MARK: - UIPickerView Delegate and DataSource methods
extension CreatePartyDetailVC: UIPickerViewDelegate, UIPickerViewDataSource {

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

extension CreatePartyDetailVC {

    // MARK: - IBActions
    @objc func dateChanged(_ sender: UIDatePicker) {

        self.selectedDate = sender.date
    }

    @IBAction func btnCancelToolbarAction(_ sender: Any) {

        self.view.endEditing(true)
        if firstResponder == 0 {
            validateInput(textField: txtFieldTime)
        } else {
            validateInput(textView: txtVwReleaseTime)
        }

//        let tuple = validateAllFields()
//        enableNextButton(shouldEnable: tuple.0)
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

            let selectedRow = self.selectedRow ?? 0
            txtVwReleaseTime.text = arrHours[selectedRow]
            if selectedRow == 0 {
                self.selectedRow = 0
            }

        }
        if firstResponder == 0 {
            validateInput(textField: txtFieldTime)
        } else {
            validateInput(textView: txtVwReleaseTime)
        }

//        let tuple = validateAllFields()
//        enableNextButton(shouldEnable: tuple.0)
        self.view.endEditing(true)
    }

    @IBAction func btnPostAction(_ sender: Any) {

        self.view.endEditing(true)

        let tuple = validateAllFields()
        if tuple.0 == true {
            self.uploadBannerImage(isDraft: false)
        } else if let errMsg = tuple.1 {
            AppUtility.showAlert("", message: errMsg, delegate: nil)
        }
    }

    @IBAction func btnNextAction(_ sender: Any) {

        self.view.endEditing(true)

        let tuple = validateAllFields()
        if tuple.0 == true {
            self.uploadBannerImage(isDraft: false)
        } else if let _ = tuple.1 {
            moveToNextTextField()
        }
    }

    @IBAction func btnBackAction(_ sender: Any) {

        let alertController = UIAlertController(title: "", message: "Do you want to save this event data?", preferredStyle: .alert)

        // Create the actions
        let okAction = UIAlertAction(title: "Yes",
                                     style: UIAlertActionStyle.default) {
                                        UIAlertAction in
                                        // call web service for saving this as draft
                                        self.uploadBannerImage(isDraft: true)
        }

        // Create the actions
        let cancelAction = UIAlertAction(title: "No",
                                         style: UIAlertActionStyle.default) {
                                            UIAlertAction in
                                            self.dismiss(animated: true, completion: nil)
        }

        // Add the actions
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)

        // Present the controller
        self.present(alertController, animated: true, completion: nil)
    }

    @IBAction func btnMainIntersectionAction(_ sender: Any) {

        self.view.endEditing(true)
        animateMainIntersection()
    }
}
