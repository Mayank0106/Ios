//
//  EventDetailVC.swift
//  Reach
//
//  Copyright © 2019 Netsolutions. All rights reserved.
//

import UIKit
import Kingfisher

protocol UpdateNewsFeed: class {
    func updateGoingStatus(isGoing: Bool, eventID: Int)
    func updateGoingCount(eventID: Int)
    func deleteEvent(eventID: Int)
}

class EventDetailVC: UIViewController, EventAPI {

    // MARK: - IBOutlets
    @IBOutlet weak var imgVwBanner: UIImageView!

    @IBOutlet weak var imgVwPic: UIImageView!

    @IBOutlet weak var lblHostName: UILabel!

    @IBOutlet weak var lblDate: UILabel!

    @IBOutlet weak var txtVwDetails: UITextView!

    @IBOutlet weak var lblEventType: UILabel!

    @IBOutlet weak var lblPartyName: UILabel!

    @IBOutlet weak var lblPartyDate: UILabel!

    @IBOutlet weak var vwDot: UIView!

    @IBOutlet weak var lblPartyTime: UILabel!

    @IBOutlet weak var lblStreet1: UILabel!

    @IBOutlet weak var lblAddressRelease: UILabel!

    @IBOutlet weak var lblAddressReleased: UILabel!

    @IBOutlet weak var lblPartyList: UILabel!

    @IBOutlet weak var lblFriendsInvited: UILabel!

    @IBOutlet weak var lblGirlBoyCount: UILabel!

    @IBOutlet weak var btnDetail: UIButton!

    @IBOutlet weak var vwImages: UIView!

    @IBOutlet weak var imgVw1: UIImageView!

    @IBOutlet weak var imgVw2: UIImageView!

    @IBOutlet weak var imgVw3: UIImageView!

    @IBOutlet weak var imgVw4: UIImageView!

    @IBOutlet weak var imgVw5: UIImageView!

    @IBOutlet weak var btnEdit: UIButton!

    @IBOutlet weak var btnRequestFriend: UIButton!

    @IBOutlet weak var btnGoing: UIButton!

    @IBOutlet weak var btnGoingSelected: UIButton!

    @IBOutlet weak var vwTransparent: UIView!

    @IBOutlet weak var btnDelete: UIButton!

    @IBOutlet weak var btnReportEvent: UIButton!

    // MARK: - Constraints
    @IBOutlet weak var constraintLblStreetHt: NSLayoutConstraint!

    @IBOutlet weak var constraintVwStreetHt: NSLayoutConstraint!

    @IBOutlet weak var constraintViewImages: NSLayoutConstraint!

    @IBOutlet weak var constraintVwOuterHt: NSLayoutConstraint!

    @IBOutlet weak var constraintExtraDetailHt: NSLayoutConstraint!

    @IBOutlet weak var constraintExtraDetailTxtVwHt: NSLayoutConstraint!

    // MARK: - Variables
    var eventID: Int?

    var eventDetail = MyEventModel()

    weak var delegate: UpdateNewsFeed?

    var imageURL: String?

    var timer = Timer()

    var eventDate = Date()

    var currentDate = Date()

    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {

        super.viewDidLoad()
       // addTimer()
        // Do any additional setup after loading the view.
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(gesture:)))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
    }
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                print("Swiped right")
                _ = self.navigationController?.popViewController(animated: true)
            default:
                break
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Pass default Image

        if let bannerImage = imageURL,
            let bannerUrl = URL(string: bannerImage) {
            imgVwBanner.kf.setImage(with: ImageResource(downloadURL: bannerUrl),
                                    placeholder: UIImage(named: "img-party"),
                                    options: [KingfisherOptionsInfoItem.cacheMemoryOnly],
                                    progressBlock: nil,
                                    completionHandler: nil)
        }
        fetchEventDetailWebService()
    }

    override func viewDidDisappear(_ animated: Bool) {

        timer.invalidate()
    }

    // MARK: - Add Tap Gesture To Delete/Report Event

    /// Add Tap Gesture To Delete/Report Event
    func addTapGestureToDeleteReportView() {

        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(removeTransparentView(sender:)))
        vwTransparent.addGestureRecognizer(tap)
    }

    /// Add Timer
    func addTimer() {

        timer = Timer.scheduledTimer(timeInterval: 1.0,
                                     target: self,
                                     selector: #selector(EventDetailVC.updateCounterTime),
                                     userInfo: nil,
                                     repeats: false)
        RunLoop.main.add(self.timer, forMode: RunLoopMode.commonModes)
    }

    /// Update counter time
    @objc func updateCounterTime() {

        let newDate = DateUtility.reduceOneSecondFromTime(date: eventDate)
        updateAddressTime(date: newDate)
    }

    // MARK: - Set UI Elements

    /// Set UI
    func setUI() {

        setGoingSelection()
        hideShowButtons()
        btnGoing.tag = eventDetail.id!
        btnDelete.tag = eventDetail.id!

        self.setEventImagesAndName()
        if let desc = eventDetail.description {

            let htRequiredForAddress = desc.height(withConstrainedWidth: 200, font: UIFont(name: "Helvetica Bold", size: 12.0)!) + 10
            constraintExtraDetailHt.constant = htRequiredForAddress + 30
            constraintExtraDetailTxtVwHt.constant = htRequiredForAddress
            txtVwDetails.text = desc
        }

        setAdddressReleaseTime()

        guard let eventType = eventDetail.eventType else { return }

        if eventType == 1 {
            lblEventType.text = "OPEN EVENT"
        } else {
            lblEventType.text = "CLOSED EVENT"
        }
        lblPartyName.text = eventDetail.name?.uppercased()

        if let street1 = eventDetail.street1Address, let street2 = eventDetail.street2Address {
            let (string, height) = AppUtility.setAttributedStringForEventDetailAddress(street1: street1,
                                                                                       street2: street2)
            lblStreet1.attributedText = string
            constraintLblStreetHt.constant = height
            constraintVwStreetHt.constant = 68 - 16 + height
        }

        if let invitationCount = eventDetail.invitationCount {
             lblPartyList.text = String(invitationCount) + " Person List"
             lblFriendsInvited.text = String(invitationCount) + " of your friends are invited"
        }

        if let femaleInvitationCount = eventDetail.femaleInvitationCount,
            let maleInvitationCount = eventDetail.maleInvitationCount {
            
            let girlsText = (String(femaleInvitationCount) == "1") ? "1 Girl" : "\(femaleInvitationCount) Girls"
            let boysText = (String(maleInvitationCount) == "1") ? "1 Boy" : "\(maleInvitationCount) Boys"

            
            lblGirlBoyCount.attributedText =
                AppUtility.setAttributedStringForEventDetail(girls: girlsText,
                                                             boys: boysText)
            
        }

        if let invitationList = eventDetail.invitationList {
            if invitationList.count > 0 {
                self.addImagesForFriends(arrFriends: invitationList)
                btnDetail.isHidden = false
                constraintViewImages.constant = 38
                constraintVwOuterHt.constant = 97
            } else {
                btnDetail.isHidden = true
                constraintViewImages.constant = 0
                constraintVwOuterHt.constant = 97 - 38
            }

        }

        self.view.updateConstraints()
        self.view.layoutIfNeeded()
    }

    /// Set Event Image & Name
    func setEventImagesAndName() {

        if let bannerImage = eventDetail.bannerImage,
            let bannerUrl = URL(string: bannerImage) {
            imgVwBanner.kf.setImage(with: ImageResource(downloadURL: bannerUrl),
                                    placeholder: UIImage(named: "img-party"),
                                    options: [KingfisherOptionsInfoItem.cacheMemoryOnly],
                                    progressBlock: nil,
                                    completionHandler: nil)
        }

        guard let hostDetails = eventDetail.host else { return }
        if let profileImageStr = hostDetails.profileImage,
            let profileImageUrl = URL(string: profileImageStr) {

            imgVwPic.kf.setImage(with: ImageResource(downloadURL: profileImageUrl),
                                 placeholder: UIImage(named: "avatarImage"),
                                 options: [KingfisherOptionsInfoItem.cacheMemoryOnly],
                                 progressBlock: nil,
                                 completionHandler: nil)
        }

        lblHostName.text = hostDetails.fullname?.uppercased()
    }

    /// Set Address Release Time
    func setAdddressReleaseTime() {

        if let date = eventDetail.startTime {
            lblPartyDate.text = DateUtility.calculateDateWeekDayFormat(date)

            if lblPartyDate.text == "" {
                vwDot.isHidden = true
            } else {
                vwDot.isHidden = false
            }
            lblPartyTime.text = DateUtility.calculateTime12HourFormat(date)
            lblDate.text = DateUtility.calculateTime12HourFormat(date)
            updateAddressTime(date: date)
        }
    }

    /// Update address Time
    ///
    /// - Parameter date: date
    func updateAddressTime(date: String) {

        guard let addressTime = eventDetail.addressTime else { return }
        if addressTime == 0 {
            lblAddressReleased.text = ""
            if let address = eventDetail.address {
                lblAddressRelease.text = address
            }
            return
        }
        
        
        let calendar = Calendar.current
        if let eventDate = DateUtility.getDate(from: date) {

            self.eventDate = eventDate
            if let date = calendar.date(byAdding: .hour,
                                        value: -addressTime,
                                        to: eventDate) {
                if DateUtility.intervalInHours(dateA: currentDate,
                                               dateB: date) < 24 {
                    if date < currentDate {
                        lblAddressReleased.text = ""
                        if let address = eventDetail.address {
                            lblAddressRelease.text = address
                        }

                    } else {
                        lblAddressReleased.text = DateUtility.intervalInHoursMinute(dateA: currentDate,
                                                                                    dateB: date)

                        addTimer()
                        lblAddressRelease.text = "Address release in : "
                    }

                } else {
                    lblAddressReleased.text = String(DateUtility.interval(dateA: currentDate,
                                                                          dateB: date)) + " days"
                    lblAddressRelease.text = "Address release in : "
                }
            }
        }
    }

    /// Hide/Show Buttons
    func hideShowButtons() {

        if isMyEvent() {
            btnDetail.isHidden = false
            btnEdit.isHidden = false
            btnRequestFriend.isHidden = true
            btnGoing.isHidden = true
            btnGoingSelected.isHidden = true
        } else {
            btnDetail.isHidden = true
            btnEdit.isHidden = true
            btnRequestFriend.isHidden = false
            setGoingSelection()
        }
    }

    /// Set Going Selection
    func setGoingSelection() {
        guard let isGoing = eventDetail.isGoing else { return }
        if isGoing {

            btnGoingSelected.isHidden = false
            btnGoing.isHidden = true
            btnGoingSelected.isUserInteractionEnabled = false
        } else {
            btnGoingSelected.isHidden = true
            btnGoing.isHidden = false

        }
    }

    /// Add Images of Top 5 friends going for the event
    ///
    /// - Parameter arrFriends: Array of friend's detail
    func addImagesForFriends(arrFriends: [FriendModel]) {

        for count in 1...5 {
            let tag = 1000 + (count - 1)
            guard let imageVw = self.vwImages.viewWithTag(tag) as? UIImageView else { return }
            imageVw.layer.cornerRadius = imageVw.frame.height / 2
            imageVw.layer.borderWidth = 2
            imageVw.layer.borderColor = UIColor.white.cgColor
            imageVw.layer.masksToBounds = true
            if count <= arrFriends.count {
                if let profileImage = arrFriends[count - 1].profileImage, let profileUrl = URL(string: profileImage) {
                    imageVw.kf.setImage(with: ImageResource(downloadURL: profileUrl),
                                        placeholder: UIImage(named: "avatarImage"),
                                        options: [KingfisherOptionsInfoItem.cacheMemoryOnly],
                                        progressBlock: nil,
                                        completionHandler: nil)

                } else {
                    imageVw.image = UIImage(named: "avatarImage")
                }
            } else {
                imageVw.backgroundColor = #colorLiteral(red: 0.8470588235, green: 0.8470588235, blue: 0.8470588235, alpha: 1)
            }
        }
    }

    // MARK: - Check If its my event
    /// Check If Is My Event
    ///
    /// - Returns: True/false
    func isMyEvent() -> Bool {

        guard let hostDetails = eventDetail.host else { return  false}
        if let data = KeychainWrapper.standard.object(forKey: AppConstants.userModelKeyChain),
            let userObj = data as? UserModel {
            if let userID = userObj.id {
                if userID == hostDetails.id! {
                    return true
                }
            }
        } else {
            return false
        }
        return false
    }

    // MARK: - Create Event Model
    /// Create Event Model
    ///
    /// - Parameter strText: Message To Report
    /// - Returns: Request Model
    func createEventModel(strText: String) -> RequestModel {

        var objModel = RequestModel()
        objModel.id = eventID
        objModel.message = strText
        return objModel
    }
    // MARK: - Button Actions
    
    @IBAction func btnProfileAction(_ sender: Any) {
    
        guard let hostDetails = eventDetail.host else { return }
        profileAction(userID: hostDetails.id)

    }
    

    // MARK: - Prepare For Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "fromEventDetailToRequestFriends" {

            guard let requestFriendVC = segue.destination as? RequestFriendsVC else { return }
            requestFriendVC.eventID = eventID

        } else if segue.identifier == "fromEventDetailToInvitationList" {

            guard let invitationListVC = segue.destination as? InvitationListVC else { return }
            invitationListVC.eventID = eventID
            invitationListVC.femaleInvitationCount = eventDetail.femaleInvitationCount
            invitationListVC.maleInvitationCount = eventDetail.maleInvitationCount
            invitationListVC.goingCount = eventDetail.goingCount
            invitationListVC.isMyEvent = isMyEvent()
        }
    }
}
