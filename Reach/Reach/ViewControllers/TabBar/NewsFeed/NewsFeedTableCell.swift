//
//  NewsFeedTableCell.swift
//  Reach
//
//  Copyright © 2019 Netsolutions. All rights reserved.
//

import UIKit
import Kingfisher

protocol GoingForEvent: class {
    func markEventAsGoing(eventID: Int, userModel: FriendModel)
    func openEditEvent(eventID: Int)
}

class NewsFeedTableCell: UITableViewCell {

    // MARK: - IBOutlets
    @IBOutlet weak var vwOuter: UIView!

    @IBOutlet weak var imgVwBanner: UIImageView!

    @IBOutlet weak var imgVwHost: UIImageView!

    @IBOutlet weak var lblHostName: UILabel!

    @IBOutlet weak var lblPartyName: UILabel!

    @IBOutlet weak var lblPartyDate: UILabel!

    @IBOutlet weak var vwDot: UIView!

    @IBOutlet weak var lblPartyTime: UILabel!

    @IBOutlet weak var lblPersonList: UILabel!

    @IBOutlet weak var lblNoOfPeopleGoing: UILabel!

    // For Showing friend's images as round circles
    @IBOutlet weak var vwImages: UIView!

    @IBOutlet weak var imgVw1: UIImageView!

    @IBOutlet weak var imgVw2: UIImageView!

    @IBOutlet weak var imgVw3: UIImageView!

    @IBOutlet weak var imgVw4: UIImageView!

    @IBOutlet weak var imgVw5: UIImageView!

    // Interest - Going/Not Going
    @IBOutlet weak var btnGoing: UIButton!

    @IBOutlet weak var btnEdit: UIButton!

    // MARK: - Variables
    weak var delegate: GoingForEvent?

    // MARK: - Initial Calls
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    // MARK: - Set Content To Cell

    /// Set Content To Cell
    ///
    /// - Parameter feed: feed details
    func setContentToCell(feed: MyEventModel) {

        if isMyEvent(feed: feed) {

            btnGoing.isHidden = true
            btnEdit.isHidden = false
        } else {
            btnGoing.isHidden = false
            btnEdit.isHidden = true

            if let going = feed.isGoing {
                btnGoing.isSelected = going
            }

            if btnGoing.isSelected {
                btnGoing.isUserInteractionEnabled = false
            } else {
                btnGoing.isUserInteractionEnabled = true
            }
        }

        guard let eventID = feed.id else { return }
        btnGoing.tag = eventID
        btnEdit.tag = eventID

        self.setEventImagesAndName(feed: feed)

        lblPartyName.text = feed.name?.uppercased()
        if let date = feed.startTime {
            lblPartyDate.text = DateUtility.calculateDateWeekDayFormat(date)

            if lblPartyDate.text == "" {
                vwDot.isHidden = true
            } else {
                vwDot.isHidden = false
            }
            lblPartyTime.text = DateUtility.calculateTime12HourFormat(date)
        }

        if let invitationCount = feed.invitationCount {
             lblPersonList.text = String(invitationCount) + " Person List"
        }

        // Add Images for people going to party
        if let peopleGoing = feed.peopleGoing {
            self.addImagesForFriends(arrFriends: peopleGoing)
        }

        // Show going count
        if let goingCount = feed.goingCount {
            // Get Logged in user ID
            guard let data = KeychainWrapper.standard.object(forKey: AppConstants.userModelKeyChain),
                let userObj = data as? UserModel,
                let userId = userObj.id else {
                    lblNoOfPeopleGoing.text = String(goingCount) + " of your friends are going"
                    return
            }
            if userId == feed.host?.id ?? 0 {
                lblNoOfPeopleGoing.text = String(goingCount) + " of your friends are going"
            } else {
                lblNoOfPeopleGoing.text = String("\(feed.invitationCount ?? 0)") + " of your friends are invited "
            }
        }
    }

    /// Set Event Image & Name
    ///
    /// - Parameter feed: feed details
    func setEventImagesAndName(feed: MyEventModel) {

        if let bannerImageStr = feed.bannerImage, let bannerImageUrl = URL(string: bannerImageStr) {
            imgVwBanner.kf.setImage(with: ImageResource(downloadURL: bannerImageUrl),
                                    placeholder: UIImage(named: "img-party"),
                                    options: [KingfisherOptionsInfoItem.cacheMemoryOnly],
                                    progressBlock: nil,
                                    completionHandler: nil)
        } else {
            imgVwBanner.image = UIImage(named: "img-party")
        }

        guard let hostDetails = feed.host else { return }
        if let profileImageStr = hostDetails.profileImage, let profileImageUrl = URL(string: profileImageStr) {

            imgVwHost.kf.setImage(with: ImageResource(downloadURL: profileImageUrl),
                                  placeholder: UIImage(named: "avatarImage"),
                                  options: [KingfisherOptionsInfoItem.cacheMemoryOnly],
                                  progressBlock: nil,
                                  completionHandler: nil)
        } else {
            imgVwHost.image = UIImage(named: "avatarImage")
        }
        lblHostName.text = hostDetails.fullname?.uppercased()
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

    // MARK: - To Check If Its my Event
    /// To check if its my event
    ///
    /// - Parameter feed: feed details
    /// - Returns: true/false

    func isMyEvent(feed: MyEventModel) -> Bool {

        guard let hostDetails = feed.host else { return  false}
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

    // MARK: - IBActions
    @IBAction func btnGoingAction(_ sender: Any) {

        guard let btn = sender as? UIButton else { return }
        if let data = KeychainWrapper.standard.object(forKey: AppConstants.userModelKeyChain),
            let userObj = data as? UserModel {

            var myModel = FriendModel()
            myModel.id = userObj.id
            myModel.username = userObj.fullname
            myModel.profileImage = userObj.profileImage
            delegate?.markEventAsGoing(eventID: btn.tag, userModel: myModel)
        }

    }

    @IBAction func btnEditAction(_ sender: Any) {

        guard let btn = sender as? UIButton else { return }
        delegate?.openEditEvent(eventID: btn.tag)
    }

}
