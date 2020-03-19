//
//  InvitationListTableViewCell.swift
//  Reach
//
//  Copyright © 2019 Netsolutions. All rights reserved.
//

import UIKit
import Kingfisher

protocol AcceptRejectInvitation: class {
    func acceptInvitation(friendID: Int)
    func rejectInvitation(friendID: Int)
}
class InvitationListTableViewCell: UITableViewCell {

    // MARK: - IBOutlets

    @IBOutlet weak var vwOuter: UIView!

    @IBOutlet weak var imgVwFriend: UIImageView!

    @IBOutlet weak var lblFriendName: UILabel!

    @IBOutlet weak var lblRequestedBringing: UILabel!

    @IBOutlet weak var vwAcceptReject: UIView!

    @IBOutlet weak var btnAccept: UIButton!

    @IBOutlet weak var btnReject: UIButton!

    // MARK: - Variables

    weak var delegate: AcceptRejectInvitation?

    // MARK: - Constraints
    @IBOutlet weak var constraintVwAcceptRejectHt: NSLayoutConstraint!

    @IBOutlet weak var constraintVwOuterHt: NSLayoutConstraint!

    var isMyEvent: Bool = false

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
    /// - Parameter upperFriendDetails: outer friend details
    func setContentToCell(friend: FriendModel, upperFriendDetails: FriendModel) {

        if let friendImageStr = friend.profileImage,
            let friendImageUrl = URL(string: friendImageStr) {

            imgVwFriend.kf.setImage(with: ImageResource(downloadURL: friendImageUrl),
                                    placeholder: UIImage(named: "avatarImage"),
                                    options: [KingfisherOptionsInfoItem.cacheMemoryOnly],
                                    progressBlock: nil,
                                    completionHandler: nil)
        }

        lblFriendName.text = friend.fullname
        if let fullName = upperFriendDetails.fullname {
             lblRequestedBringing.text = "With " + fullName
        }

        guard let friendID = friend.id else { return }
        lblRequestedBringing.tag = friendID
        btnAccept.tag = friendID
        btnReject.tag = friendID

        guard let isInvited = friend.isInvited else { return }

        if !isMyEvent {
            constraintVwAcceptRejectHt.constant = 0
            constraintVwOuterHt.constant = 66

        } else {
            if isInvited {
                constraintVwAcceptRejectHt.constant = 0
                constraintVwOuterHt.constant = 66
            } else {
                constraintVwAcceptRejectHt.constant = 33
                constraintVwOuterHt.constant = 112
            }
        }

    }

    // MARK: - IBActions
    @IBAction func btnAcceptAction(_ sender: Any) {
        guard let btn = sender as? UIButton else { return }
        delegate?.acceptInvitation(friendID: btn.tag)
    }

    @IBAction func btnRejectAction(_ sender: Any) {
        guard let btn = sender as? UIButton else { return }
        delegate?.rejectInvitation(friendID: btn.tag)
    }
}
