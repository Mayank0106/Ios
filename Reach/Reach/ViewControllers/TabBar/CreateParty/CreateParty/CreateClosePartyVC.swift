//
//  CreateClosePartyVC.swift
//  Reach
//
//  Copyright © 2019 Netsolutions. All rights reserved.
//

import UIKit
import Kingfisher

class CreateClosePartyVC: UIViewController, FriendAPI {

    // MARK: - IBOutlets
    @IBOutlet weak var txtPartyName: FloatLabelTextField!

    @IBOutlet weak var btnNext: UIButton!

    @IBOutlet weak var lblBannerSmall: UILabel!

    @IBOutlet weak var lblBannerBig: UILabel!

    @IBOutlet weak var btnBannerImage: UIButton!

    @IBOutlet weak var imgBanner: UIImageView!

    @IBOutlet weak var imgOverlay: UIImageView!

    //View Of Inviting friends
    @IBOutlet weak var vwInviteFriends: UIView!

    @IBOutlet weak var lblNoOfFriendsSelected: UILabel!

    @IBOutlet weak var imgVw1: UIImageView!

    @IBOutlet weak var imgVw2: UIImageView!

    @IBOutlet weak var imgVw3: UIImageView!

    @IBOutlet weak var imgVw4: UIImageView!

    @IBOutlet weak var imgVw5: UIImageView!

    // MARK: - Constraints
    @IBOutlet weak var constraintVwInviteFriends: NSLayoutConstraint!

    @IBOutlet weak var constraintNavBarHt: NSLayoutConstraint!

    // MARK: - Variables

    //Check If Friend list is Closed/Open
    var isFriendsListOpen: Bool = false

    let closedSizeFriendListField: CGFloat = 49

    let openSizeFriendListField: CGFloat = 103

    //Array of friends selected for Invitation
    var arrFriends = [FriendModel]()

    // Handler of AWS Utility to show that images are uploaded
    var objectAWSProtocol: AWSProtocol?

    // Event Type from Segue - Define Event
    var eventType: Int?

    let maxPartyNameLength = 60

    var selectedFriends = [FriendModel]()

    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {

        super.viewDidLoad()
        setUI()
        enableNextButton(shouldEnable: false)
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

    // MARK: - Setting Up UI

    /// Set UI Elements
    func setUI() {
        if isFriendsListOpen {
            constraintVwInviteFriends.constant = openSizeFriendListField
            self.setUpFriendsImageList()
        } else {
            constraintVwInviteFriends.constant = closedSizeFriendListField
        }
    }

    /// Enable Next Button
    ///
    /// - Parameter shouldEnable: should enable
    func enableNextButton(shouldEnable: Bool) {

        if shouldEnable {
            btnNext.isUserInteractionEnabled = true
            btnNext.alpha = 1
        } else {
            btnNext.isUserInteractionEnabled = false
            btnNext.alpha = 0.5
        }
    }

    /// For Showing friend's images as round circles
    func setUpFriendsImageList() {

        self.lblNoOfFriendsSelected.text = String(self.selectedFriends.count)
            + "PeopleInvited".localized

        for index in 1...5 {
            let tag = 1000 + (index - 1)
            guard let imagePartyVw = self.vwInviteFriends.viewWithTag(tag)
                as? UIImageView else { return }

            if index <= self.selectedFriends.count {

                if let profileImage = self.selectedFriends[index - 1].profileImage,
                    let profileUrl = URL(string: profileImage) {
                    imagePartyVw.kf.setImage(with: ImageResource(downloadURL: profileUrl),
                                        placeholder: UIImage(named: "avatarImage"),
                                        options: [KingfisherOptionsInfoItem.cacheMemoryOnly],
                                        progressBlock: nil,
                                        completionHandler: nil)

                } else {
                    imagePartyVw.image = UIImage(named: "avatarImage")
                }
                imagePartyVw.layer.cornerRadius = imagePartyVw.frame.height / 2
                imagePartyVw.layer.borderWidth = 2
                imagePartyVw.layer.borderColor = UIColor.white.cgColor
                imagePartyVw.isHidden = false
                imagePartyVw.layer.masksToBounds = true
            } else {
                imagePartyVw.isHidden = true
            }
        }
    }

    // MARK: - Validate Fields

    /// Validate All Fields
    ///
    /// - Returns: Status
    func validateAllFields() -> (Bool, String?) {

        if txtPartyName.text!.isEmpty {
            return (false, "Enter party name")

        } else if imgBanner.image == nil {
            return (false, "PleaseSelectBannerImage".localized)

        }
        return (true, nil)
    }

    // MARK: - IBActions

    @IBAction func btnInviteFriendsAction(_ sender: Any) {
        self.view.endEditing(true)
        guard let inviteFriendsVC = tabBarStoryboard.instantiateViewController(withIdentifier: "InviteFriendsVC")
            as? InviteFriendsVC else { return }

        inviteFriendsVC.delegate = self
        inviteFriendsVC.arrSelectedFriendList = self.selectedFriends
        self.present(inviteFriendsVC,
                     animated: true,
                     completion: nil)

    }

    @IBAction func btnSelectBannerAction(_ sender: Any) {

        lblBannerSmall.isHidden = false
        lblBannerBig.isHidden = true

        self.objectAWSProtocol = AWSProtocol(resizeHandler: { (_, resizedThumbImage) in
            self.imgBanner.image = resizedThumbImage
            self.imgOverlay.isHidden = false
            let tuple = self.validateAllFields()
            self.enableNextButton(shouldEnable: tuple.0)

        }, onComplete: { (_, _) in
            print("Download complete")
        })

        self.objectAWSProtocol?.showActionSheetForImage(controller: self)
    }

    @IBAction func btnBackArrowAction(_ sender: Any) {

        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func btnNextArrowAction(_ sender: Any) {

        self.view.endEditing(true)

        self.performSegue(withIdentifier: "CreatePartyDetailSegue",
                          sender: nil)
    }

    // MARK: - Prepare For Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "CreatePartyDetailSegue" {

            guard let partyDetailVC = segue.destination
                as? CreatePartyDetailVC else { return }

            partyDetailVC.eventType = eventType
            partyDetailVC.eventName = txtPartyName.text!

            partyDetailVC.arrRecipients = selectedFriends
            partyDetailVC.eventBanner = self.imgBanner.image
        }
    }
}

// MARK: - SelectedFriendsList delegate methods
extension CreateClosePartyVC: SelectedFriendsList {

    func sendBackSelectedFriendList(arrSelectedFriends: [FriendModel]) {

        self.selectedFriends = arrSelectedFriends

        if self.selectedFriends.count > 0 {
            isFriendsListOpen = true
        } else {
            isFriendsListOpen = false
        }
        setUI()
    }
}

// MARK: - UITextField delegate methods
extension CreateClosePartyVC: UITextFieldDelegate {

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
        textField.text = newText
        let tuple = validateAllFields()
        enableNextButton(shouldEnable: tuple.0)
        return false
    }

}
