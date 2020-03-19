//
//  FriendTableViewCell.swift
//  Reach
//
//  Copyright © 2019 Netsolutions. All rights reserved.
//

import UIKit
import Kingfisher

protocol PerformActionsOnFriends: class {
      func unFriend(sender: UIButton)
      func acceptRequest(sender: UIButton)
      func addFriend(sender: UIButton)
}

class FriendTableViewCell: UITableViewCell {

    // MARK: - IBOutlets
    @IBOutlet weak var vwOuter: UIView!

    @IBOutlet weak var imgVwFriend: UIImageView!

    @IBOutlet weak var lblFriendName: LabelFontConstraint!

    @IBOutlet weak var lblUsername: LabelFontConstraint!

    @IBOutlet weak var btnUnFriend: UIButton!

    @IBOutlet weak var btnAccept: ButtonFontConstraint!

    @IBOutlet weak var btnAdd: ButtonFontConstraint!

    @IBOutlet weak var btnSent: ButtonFontConstraint!

    weak var delegate: PerformActionsOnFriends?

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

        btnUnFriend.isHidden = true
        btnAccept.isHidden = true
        btnAdd.isHidden = true
        btnSent.isHidden = true

        if let friendImageStr = friend.profileImage,
            let friendImageUrl = URL(string: friendImageStr) {

            imgVwFriend.kf.setImage(with: ImageResource(downloadURL: friendImageUrl),
                                    placeholder: UIImage(named: "avatarImage"),
                                    options: [KingfisherOptionsInfoItem.cacheMemoryOnly],
                                    progressBlock: nil,
                                    completionHandler: nil)
        }

        lblFriendName.text = friend.fullname
        lblUsername.text = friend.username

        guard let friendID = friend.id else { return }
        btnUnFriend.tag = friendID
        btnAdd.tag = friendID
        btnSent.tag = friendID
        btnAccept.tag = friendID

        guard let friendStatus = friend.friendStatus else { return }
        switch friendStatus {
        case 0:
            btnAdd.isHidden = false
        case 2:
            btnSent.isHidden = false
        case 3:
            btnAccept.isHidden = false
        default:
            btnUnFriend.isHidden = false
        }

    }

    // MARK: - IBActions

    @IBAction func btnUnFriendAction(_ sender: Any) {

        guard let btn = sender as? UIButton else { return }
        delegate?.unFriend(sender: btn)
    }

    @IBAction func btnAcceptAction(_ sender: Any) {

        guard let btn = sender as? UIButton else { return }
        delegate?.acceptRequest(sender: btn)
    }

    @IBAction func btnAddAction(_ sender: Any) {

        guard let btn = sender as? UIButton else { return }
        delegate?.addFriend(sender: btn)
    }

    @IBAction func btnRequestSentAction(_ sender: Any) {

    }
}
