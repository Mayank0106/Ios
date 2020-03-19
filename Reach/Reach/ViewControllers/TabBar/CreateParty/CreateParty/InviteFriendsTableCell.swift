//
//  InviteFriendsTableCell.swift
//  Reach
//
//  Copyright © 2019 Netsolutions. All rights reserved.
//

import UIKit
import Kingfisher

class InviteFriendsTableCell: UITableViewCell {

    // MARK: - IBOutlets
    @IBOutlet weak var imgVwPic: UIImageView!

    @IBOutlet weak var lblName: UILabel!

    @IBOutlet weak var btnSelect: UIButton!

    @IBOutlet weak var btnAddInvite: UIButton!

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
    /// - Parameters:
    ///   - friend: Friend Details
    ///   - isFriendsView: Is Friends View
    func setContentToCell(friend: FriendModel, isFriendsView: Bool = false, isEditEvent: Bool = false) {

        if let friendImageStr = friend.profileImage, let friendImageUrl = URL(string: friendImageStr) {

            imgVwPic.kf.setImage(with: ImageResource(downloadURL: friendImageUrl),
                                 placeholder: UIImage(named: "avatarImage"),
                                 options: [KingfisherOptionsInfoItem.cacheMemoryOnly],
                                 progressBlock: nil,
                                 completionHandler: nil)
        }

        lblName.text = friend.fullname

        if isFriendsView {

            if isEditEvent {
                btnSelect.isSelected = friend.isInvited!
            } else {
                btnSelect.isSelected = friend.isSelected
            }

            if btnSelect.isSelected {
                self.backgroundColor = #colorLiteral(red: 0.9019607843, green: 0.1960784314, blue: 0.1960784314, alpha: 1)
                self.lblName.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            } else {
                self.backgroundColor = UIColor.white
                self.lblName.textColor = #colorLiteral(red: 0.2039215686, green: 0.2039215686, blue: 0.2039215686, alpha: 1)
            }
        } else {

            if isEditEvent {
                btnAddInvite.isSelected = friend.isInvited!
            } else {
                btnAddInvite.isSelected = friend.isSelected
            }
        }
    }
}
