//
//  InvitationListSectionHeader.swift
//  Reach
//
//  Copyright © 2019 Netsolutions. All rights reserved.
//

import UIKit
import Kingfisher

protocol CollapseExpandSectionHeader: class {
    func collapseExpandSectionHeader(friendID: Int, isSelected: Bool)
}

class InvitationListSectionHeader: UITableViewCell {

    // MARK: - IBOutlets

    @IBOutlet weak var imgVwFriend: UIImageView!

    @IBOutlet weak var lblFriendName: UILabel!

    @IBOutlet weak var lblRequestedBringing: UILabel!

    @IBOutlet weak var btnGoing: UIButton!

    @IBOutlet weak var btnArrow: UIButton!

    @IBOutlet weak var btnOverlay: UIButton!

    @IBOutlet weak var constraintNameTop: NSLayoutConstraint!

    weak var delegate: CollapseExpandSectionHeader?

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
    /// - Parameter friend: friend details
    func setContentToCell(friend: FriendModel) {

        if let friendImageStr = friend.profileImage,
            let friendImageUrl = URL(string: friendImageStr) {

            imgVwFriend.kf.setImage(with: ImageResource(downloadURL: friendImageUrl),
                                    placeholder: UIImage(named: "avatarImage"),
                                    options: [KingfisherOptionsInfoItem.cacheMemoryOnly],
                                    progressBlock: nil,
                                    completionHandler: nil)
        }

        lblFriendName.text = friend.fullname
        guard let arrRequestedInvites = friend.arrRequestedInvitations,
            let isGoing = friend.isGoing else { return }

        if arrRequestedInvites.count > 0 {

             lblRequestedBringing.text = "Requesting/Bringing " +
                String(arrRequestedInvites.count) + " friends"

             constraintNameTop.constant = 12.5
             btnArrow.isHidden = false
        } else {
             lblRequestedBringing.text = ""
             constraintNameTop.constant = 21.5
             btnArrow.isHidden = true
        }

        if isGoing {
            btnGoing.isHidden = false
        } else {
            btnGoing.isHidden = true
        }
        btnArrow.isSelected = friend.isSelected
        guard let friendID = friend.id else { return }
        lblRequestedBringing.tag = friendID
        btnOverlay.tag = friendID
        btnOverlay.isSelected = friend.isSelected

    }

    // MARK: - IBActions

    @IBAction func btnOverlayAction(_ sender: Any) {

        guard let btn = sender as? UIButton else { return }
        btn.isSelected = !btn.isSelected
        delegate?.collapseExpandSectionHeader(friendID: btn.tag,
                                              isSelected: btn.isSelected)

    }
}
