//
//  EditEventVC.swift
//  Reach
//
//  Created by Aanchal Jain on 19/03/19.
//  Copyright © 2019 Netsolutions. All rights reserved.
//

import UIKit
import Kingfisher

class EditEventVC: UIViewController, EventAPI {

    // MARK: - IBOutlets

    @IBOutlet weak var vwCloseEvent: UIView!

    @IBOutlet weak var vwOpenEvent: UIView!

    @IBOutlet weak var txtPartyName: TextFontConstraint!

    //View Of Inviting friends
    @IBOutlet weak var vwInviteFriends: UIView!

    @IBOutlet weak var lblNoOfFriendsSelected: UILabel!

    @IBOutlet weak var imgVw1: UIImageView!

    @IBOutlet weak var imgVw2: UIImageView!

    @IBOutlet weak var imgVw3: UIImageView!

    @IBOutlet weak var imgVw4: UIImageView!

    @IBOutlet weak var imgVw5: UIImageView!

    @IBOutlet weak var lblBannerSmall: UILabel!

    @IBOutlet weak var lblBannerBig: UILabel!

    @IBOutlet weak var btnBannerImage: UIButton!

    @IBOutlet weak var imgVwBanner: UIImageView!

    @IBOutlet weak var imgOverlay: UIImageView!

    @IBOutlet weak var txtVwAddress: TextViewFontConstraint!

    @IBOutlet weak var btnMainIntersection: ButtonFontConstraint!

    @IBOutlet weak var txtFieldStreet1: TextFontConstraint!

    @IBOutlet weak var txtFieldStreet2: TextFontConstraint!

    @IBOutlet weak var txtFieldTime: TextFontConstraint!

    @IBOutlet weak var txtVwReleaseTime: TextViewFontConstraint!

    @IBOutlet weak var txtVwExtraDetails: TextViewFontConstraint!

    // MARK: - Offline Views
    @IBOutlet var vwPicker: UIView!

    @IBOutlet var toolBar: UIToolbar!

    @IBOutlet weak var pickerView: UIPickerView!

    @IBOutlet var vwDatePicker: UIView!

    @IBOutlet weak var toolBarDatePicker: UIToolbar!

    @IBOutlet var datePicker: UIDatePicker!

    // MARK: - Constraints
    @IBOutlet weak var constraintVwInviteFriends: NSLayoutConstraint!

    @IBOutlet weak var constraintTxtFieldStreet1Ht: NSLayoutConstraint!

    @IBOutlet weak var constraintTxtFieldStreet2Ht: NSLayoutConstraint!

    //Check If Friend list is Closed/Open
    var isFriendsListOpen: Bool = false

    let closedSizeFriendListField: CGFloat = 0

    let openSizeFriendListField: CGFloat = 103

    // Handler of AWS Utility to show that images are uploaded
    var objectAWSProtocol: AWSProtocol?

    var selectedFriends = [FriendModel]()

    var eventID: Int?

    var eventDetail: MyEventModel?

    var eventType: Int?

    // For Showing data in picker
    var arrHours = ["When Posted", "1 hour", "2 hours", "3 hours", "5 hours", "10 hours", "1 day", "2 days", "3 days", "7 days"]

    var selectedRow: Int? // Picker Selected Row

    var selectedDate: Date? // Date Picker selected date

    var datePickerDate: Date?

    var firstResponder = -1

    let maxAddressLength = 100

    let maxStreetLength = 30

    let maxPartyNameLength = 60

    var isImageChange: Bool = false

    var isFromEventDetail = false

    // MARK:- View Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        textFieldsSettings()
        datePickerSettings()
        getDataWebService()
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
        setNavBarHide(hide: true)
    }

    // MARK: - Initialization Methods

    // Text Field Settings
    func textFieldsSettings() {
        txtFieldTime.inputView = vwDatePicker
        txtVwReleaseTime.inputView = vwPicker
        txtFieldTime.inputAccessoryView = UIView()
        txtVwReleaseTime.inputAccessoryView = UIView()
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

    /// Set Data Manager
    func setDataManager() {

        guard let event = eventDetail else { return }
        if let eventType = event.eventType {
            self.eventType = eventType
            setEventType(eventType: eventType, isFirstTime: true)
        }

        // Display Event Name
        txtPartyName.text = event.name

        if let bannerImage = event.bannerImage,
            let bannerUrl = URL(string: bannerImage) {
            // Show small Image if have Image
            lblBannerSmall.isHidden = false
            lblBannerBig.isHidden = true
            // Download an Image
            imgVwBanner.kf.setImage(with: ImageResource(downloadURL: bannerUrl),
                                    placeholder: UIImage(named: "img-party"),
                                    options: [KingfisherOptionsInfoItem.cacheMemoryOnly],
                                    progressBlock: nil,
                                    completionHandler: nil)
        }

        txtVwAddress.text = event.address
        txtVwAddress.layoutSubviews()

        txtFieldStreet1.text = event.street1Address
        txtFieldStreet2.text = event.street2Address
        if let addressTime = event.addressTime {
            txtVwReleaseTime.text = showAddressTimeInHoursDays(addressTime: addressTime)
            txtVwReleaseTime.layoutSubviews()
        }

        if let startTime = event.startTime {
            guard let date = DateUtility.getDate(from: startTime) else { return }
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
        }

        txtVwExtraDetails.text = event.description
        txtVwExtraDetails.layoutSubviews()
    }

    /// Set Event Type
    ///
    /// - Parameter eventType: Event Type
    func setEventType(eventType: Int, isFirstTime: Bool = false) {

        if eventType == 1 {
            vwOpenEvent.backgroundColor = #colorLiteral(red: 0.1725490196, green: 0.6470588235, blue: 0.0862745098, alpha: 1)
            vwCloseEvent.backgroundColor = UIColor.clear //#colorLiteral(red: 0.1725490196, green: 0.6470588235, blue: 0.0862745098, alpha: 1)

            constraintVwInviteFriends.constant = closedSizeFriendListField

            if !isFirstTime {
                self.selectedFriends = []
                self.setUpFriendsList()
            }

        } else {

            vwOpenEvent.backgroundColor = UIColor.clear // #colorLiteral(red: 0.1725490196, green: 0.6470588235, blue: 0.0862745098, alpha: 1)  //
            vwCloseEvent.backgroundColor = #colorLiteral(red: 0.9019607843, green: 0.1960784314, blue: 0.1960784314, alpha: 1)

            constraintVwInviteFriends.constant = openSizeFriendListField
            guard let event = eventDetail else { return }

            if isFirstTime {
                if let selectedFriends = event.invitationList {
                    self.selectedFriends = selectedFriends
                    self.setUpFriendsList()
                }
            } else {
                self.selectedFriends = []
                self.setUpFriendsList()
            }

        }
    }

    /// For Showing friend's images as round circles
    func setUpFriendsList() {

        self.lblNoOfFriendsSelected.text = String(self.selectedFriends.count)
            + "PeopleInvited".localized

        for count in 1...5 {
            let tag = 1000 + (count - 1)
            guard let imageVw = self.vwInviteFriends.viewWithTag(tag)
                as? UIImageView else { return }

            if count <= self.selectedFriends.count {

                if let profileImage = self.selectedFriends[count - 1].profileImage,
                    let profileUrl = URL(string: profileImage) {
                    imageVw.kf.setImage(with: ImageResource(downloadURL: profileUrl),
                                        placeholder: UIImage(named: "avatarImage"),
                                        options: [KingfisherOptionsInfoItem.cacheMemoryOnly],
                                        progressBlock: nil,
                                        completionHandler: nil)

                } else {
                    imageVw.image = UIImage(named: "avatarImage")
                }
                imageVw.layer.cornerRadius = imageVw.frame.height / 2
                imageVw.layer.borderWidth = 2
                imageVw.layer.borderColor = UIColor.white.cgColor
                imageVw.isHidden = false
                imageVw.layer.masksToBounds = true
            } else {
                imageVw.isHidden = true
            }
        }
    }

    // MARK: - Validate Fields

    /// Validate All Fields
    ///
    /// - Returns: Status
    func validateAllFields() -> (Bool, String?) {

        if txtPartyName.text!.isEmpty || imgVwBanner.image == nil || txtVwAddress.text!.isEmpty || txtFieldStreet1.text!.isEmpty || txtFieldStreet2.text!.isEmpty
            || txtFieldTime.text!.isEmpty || txtVwReleaseTime.text!.isEmpty || txtVwExtraDetails.text!.isEmpty {

            return (false, "AllFieldsAreMandatory".localized)
        }
        return (true, nil)
    }

    // MARK: - Upload Banner Image to AWS

    /// Upload Banner Image
    func uploadBannerImage(isDraft: Bool) {

        if !AppUtility.isNetworkAvailable() {
            AppUtility.showAlert("",
                                 message: "NetworkError".localized,
                                 delegate: self)
            return
        }

        guard let eventBannerImage = imgVwBanner.image else { return }
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
                self.editPartyEventWebService(bannerImageURL: imageUrl)
            } else {
                self.dismissLoader()
                AppUtility.showAlert("",
                                     message: "UnableToUploadProfileImage".localized,
                                     delegate: nil)
            }
        }
    }

    // MARK: - Create Event Model To Upload

    /// Create Event Model
    ///
    /// - Returns: Event Model
    func createEventModel(bannerImageURL: String?) -> MyEventModel? {

        var objEvent = MyEventModel()

        if let eventType = self.eventType {
            objEvent.eventType = eventType
        }

        objEvent.name = txtPartyName.text!
        objEvent.bannerImage = bannerImageURL
        objEvent.address = txtVwAddress.text!
        objEvent.street1Address = txtFieldStreet1.text!
        objEvent.street2Address = txtFieldStreet2.text!

        if let selectedRow = self.selectedRow {

                objEvent.addressTime = calculateAddressTime(rowNo: selectedRow)

        } else {
            if let event = eventDetail {

                objEvent.addressTime = event.addressTime
            }
        }

        if let selectedDate = self.selectedDate {
            let strDate = DateUtility.getDateStr(from: selectedDate)
            objEvent.startTime = strDate
        } else {

            if let event = eventDetail {

                objEvent.startTime = event.startTime
            }
        }
        objEvent.description = txtVwExtraDetails.text!
        objEvent.arrRecipients = self.selectedFriends
        objEvent.draft = false
        return objEvent
    }
}
