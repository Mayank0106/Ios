//
//  CreatePartyDetailVC.swift
//  Reach
//
//  Copyright © 2019 Netsolutions. All rights reserved.
//

import UIKit

class CreatePartyDetailVC: UIViewController, EventAPI {

    // MARK: - IBOutlets
    @IBOutlet weak var txtVwAddress: TextViewFontConstraint!

    @IBOutlet weak var btnMainIntersection: ButtonFontConstraint!

    @IBOutlet weak var txtFieldStreet1: TextFontConstraint!

    @IBOutlet weak var txtFieldStreet2: TextFontConstraint!

    @IBOutlet weak var txtFieldTime: TextFontConstraint!

    @IBOutlet weak var txtVwReleaseTime: TextViewFontConstraint!

    @IBOutlet weak var txtVwExtraDetails: TextViewFontConstraint!

    @IBOutlet weak var btnPost: ButtonFontConstraint!

    @IBOutlet weak var lblEventDetail: UILabel!

    // MARK: - Offline Views
    @IBOutlet var vwPicker: UIView!

    @IBOutlet var toolBar: UIToolbar!

    @IBOutlet weak var pickerView: UIPickerView!

    @IBOutlet var vwDatePicker: UIView!

    @IBOutlet weak var toolBarDatePicker: UIToolbar!

    @IBOutlet var datePicker: UIDatePicker!

    @IBOutlet var vwNext: UIView!

    @IBOutlet weak var btnNext: ButtonFontConstraint!

    // MARK: - Constraints
    @IBOutlet weak var constraintNavBarHt: NSLayoutConstraint!

    @IBOutlet weak var constraintTxtFieldStreet1Top: NSLayoutConstraint!

    @IBOutlet weak var constraintTxtFieldStreet1Ht: NSLayoutConstraint!

    @IBOutlet weak var constraintTxtFieldStreet2Top: NSLayoutConstraint!

    @IBOutlet weak var constraintTxtFieldStreet2Ht: NSLayoutConstraint!

    // Data from Segue - Create Open/Close Party
    var eventType: Int?

    var eventName: String?

    var eventBanner: UIImage?

    var arrRecipients = [FriendModel]()

    // For Showing data in picker
    var arrHours = ["When Posted", "1 hour", "2 hours", "3 hours", "5 hours", "10 hours", "1 day", "2 days", "3 days", "7 days"]

    var selectedRow: Int? // Picker Selected Row

    var selectedDate: Date? // Date Picker selected date

    var datePickerDate: Date?

    var firstResponder = -1

    let maxAddressLength = 100

    let maxStreetLength = 30

    var currentResponder: Any?

    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {

        super.viewDidLoad()
        setUI()
        textFieldsSettings()
       // enableNextButton(shouldEnable: false)
        datePickerSettings()

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
    // MARK: - Set UI

    /// Set UI
    func setUI() {

        if eventType == 1 {
            lblEventDetail.text = "THIS IS A OPEN EVENT\nALL YOUR FRIENDS CAN VIEW THIS EVENT"
        } else {
            lblEventDetail.text = "THIS IS A CLOSED EVENT\nALL PEOPLE INVITED CAN VIEW THIS EVENT"
        }
    }

    /// Move To Next Tsext Field
    func moveToNextTextField() {

        if let currentTextField = currentResponder as? UITextField {

            let tag = currentTextField.tag
            if let nextField = currentTextField.superview?.viewWithTag(tag + 1) as? UITextField {
                nextField.becomeFirstResponder()
            } else if let nextField = currentTextField.superview?.viewWithTag(tag + 1) as? UITextView {
                nextField.becomeFirstResponder()
            } else {
                currentTextField.resignFirstResponder()
            }
        } else if let currentTextView = currentResponder as? UITextView {

            let tag = currentTextView.tag
            if tag == 1000 {

                animateMainIntersection()
            }
            if let nextField = currentTextView.superview?.viewWithTag(tag + 1) as? UITextField {
                nextField.becomeFirstResponder()
            } else if let nextField = currentTextView.superview?.viewWithTag(tag + 1) as? UITextView {
                nextField.becomeFirstResponder()
            } else {
                currentTextView.resignFirstResponder()
            }
        }
    }

    /// Animate Main Intersection
    func animateMainIntersection() {

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
                        self.constraintTxtFieldStreet1Top.constant = 0
                        self.constraintTxtFieldStreet2Top.constant = 0
                        self.view.updateConstraints()
                        self.view.layoutIfNeeded()

        }, completion: { (finished) -> Void in
            // ....
        })
    }

    // MARK:- Initialization Methods

    /// Text Field Settings
    func textFieldsSettings() {

        txtVwAddress.inputAccessoryView = vwNext
        txtFieldStreet1.inputAccessoryView = vwNext
        txtFieldStreet2.inputAccessoryView = vwNext

        txtFieldTime.inputAccessoryView = vwNext
        txtFieldTime.inputView = vwDatePicker

        txtVwReleaseTime.inputAccessoryView = vwNext
        txtVwReleaseTime.inputView = vwPicker

        txtVwExtraDetails.inputAccessoryView = vwNext
    }

    /// Date Picker Settings
    func datePickerSettings() {

        datePicker.addTarget(self,
                             action: #selector(dateChanged(_:)),
                             for: .valueChanged)

        datePicker.datePickerMode = .dateAndTime

        let calendar = Calendar.current
        datePickerDate = calendar.date(byAdding: .hour,
                                       value: 2,
                                       to: Date())

        datePicker.minimumDate = datePickerDate
        datePicker.locale = Locale.current
        datePicker.timeZone = NSTimeZone.local
    }

    // MARK: - Validate Fields

    /// Validate All Fields
    ///
    /// - Returns: Status
    func validateAllFields() -> (Bool, String?) {

        if txtVwAddress.text!.isEmpty || txtFieldStreet1.text!.isEmpty || txtFieldStreet2.text!.isEmpty
            || txtFieldTime.text!.isEmpty || txtVwReleaseTime.text!.isEmpty || txtVwExtraDetails.text!.isEmpty {

            return (false, "AllFieldsAreMandatory".localized)
        }
        return (true, nil)
    }

    /// Validate Every Text Input
    ///
    /// - Parameter textField: Text Field
    func validateInput(textField: UITextField) {

        let strText = textField.text!.trimmingCharacters(in: .whitespacesAndNewlines)

        if textField == txtFieldStreet1 {
            txtFieldStreet1.errorMessage = nil
            if strText.isEmpty {
                txtFieldStreet1.errorMessage = "Street1 is mandatory"
                return
            }
        }

        if textField == txtFieldStreet2 {
            txtFieldStreet2.errorMessage = nil
            if strText.isEmpty {
                txtFieldStreet2.errorMessage = "Street2 is mandatory"
                return
            }
        }

        if textField == txtFieldTime {
            txtFieldTime.errorMessage = nil
            if strText.isEmpty {
                txtFieldTime.errorMessage = "Address Time is mandatory"
                return
            }
        }
    }

    /// Validate Every Text Input
    ///
    /// - Parameter textView: Text View
    func validateInput(textView: UITextView) {

        let strText = textView.text!.trimmingCharacters(in: .whitespacesAndNewlines)

        if textView == txtVwAddress {
            if strText.isEmpty {
                return
            }
        }

        if textView == txtVwExtraDetails {
            if strText.isEmpty {
                return
            }
        }

        if textView == txtVwReleaseTime {
            if strText.isEmpty {
                return
            }
        }
    }

    // MARK: - Upload Banner Image to AWS

    /// Upload Banner Image
    func uploadBannerImage(isDraft: Bool) {

        if !AppUtility.isNetworkAvailable() {
            AppUtility.showAlert("", message: "NetworkError".localized, delegate: self)
            return
        }

        guard let eventBannerImage = eventBanner else { return }
        showLoader()

        let imageNameGuid = UUID().uuidString.lowercased()
        let folderName = "bannerImages/"
        let imageName = "\(imageNameGuid).jpeg"
        AWSProtocol.uploadImage(image: eventBannerImage,
                                imageName: imageName,
                                s3FolderName: folderName,
                                controller: self,
                                progressHandler: { (progress: Float) in

        }) { (isCompleted: Bool, error: Error?) in
            if isCompleted {

                let imageUrl = Configuration.s3Path() + folderName + imageName
                print("Uploaded image url: \(imageUrl)")
                self.createPartyEventWebService(bannerImageURL: imageUrl,
                                                isDraft: isDraft)
            } else {
                self.dismissLoader()
                AppUtility.showAlert("", message: "UnableToUploadProfileImage".localized, delegate: nil)
            }
        }
    }

    // MARK: - Create Event Model To Upload

    /// Create Event Model
    ///
    /// - Parameter bannerImageURL: Banner Image URL
    /// - Parameter isDraft: is Draft
    /// - Returns: Event Model
    func createEventModel(bannerImageURL: String?, isDraft: Bool) -> MyEventModel? {

        var objEvent = MyEventModel()
        guard let eventType = eventType, let name = eventName else { return nil }

        objEvent.eventType = eventType
        objEvent.name = name
        objEvent.bannerImage = bannerImageURL
        objEvent.address = txtVwAddress.text!
        objEvent.street1Address = txtFieldStreet1.text!
        objEvent.street2Address = txtFieldStreet2.text!

        if let selectedRow = self.selectedRow {
            objEvent.addressTime = calculateAddressTime(rowNo: selectedRow)
        }

        if let selectedDate = self.selectedDate {
            let strDate = DateUtility.getDateStr(from: selectedDate)
            objEvent.startTime = strDate
        }

        objEvent.description = txtVwExtraDetails.text!
        objEvent.arrRecipients = self.arrRecipients
        objEvent.draft = isDraft
        return objEvent
    }

    /// Calculate Address Time
    ///
    /// - Parameter rowNo: Row No
    /// - Returns: Hours
    func calculateAddressTime(rowNo: Int) -> Int {

        print(rowNo)
        var addressTime = 0
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

    // MARK: - Web service calls

    /// Create Party Event Web Service
    ///
    /// - Parameter bannerImageURL: Banner Image URL
    /// - Parameter isDraft: isDraft
    func createPartyEventWebService(bannerImageURL: String?, isDraft: Bool) {

        self.view.endEditing(true)
        if !AppUtility.isNetworkAvailable() {
            AppUtility.showAlert("", message: "NetworkError".localized, delegate: self)
            return
        }

        guard let eventModel = self.createEventModel(bannerImageURL: bannerImageURL,
                                                     isDraft: isDraft) else { return }

        createEvent(eventModel, withHandler: { (eventDetails, isFromCache)  in

            guard let eventInfo = eventDetails else { return }

            if eventInfo.status == AppConstants.successServiceCode {

                guard let tabbar = appDelegate.window?.rootViewController
                    as? UITabBarController else { return }

                guard let newsFeedNavController = tabbar.viewControllers?[0]
                    as? UINavigationController else { return }
                guard let newsFeedController = newsFeedNavController.viewControllers[0]
                    as? NewsFeedVC else { return }

                newsFeedController.refreshDataWithNewEvents()
                self.dismiss(animated: true, completion: nil)

            } else if eventInfo.status == AppConstants.tokenExpired {
                appDelegate.navigationToLoginIfAppTokenNotAvailableOrLogOut()
            } else {

                AppUtility.showAlert("", message: eventInfo.message, delegate: nil)
            }
        }) { (error) in
            AppUtility.showAlert("", message: "Error", delegate: nil)
        }
    }
}
