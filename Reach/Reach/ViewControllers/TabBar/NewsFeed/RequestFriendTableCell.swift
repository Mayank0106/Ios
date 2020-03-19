//
//  RequestFriendTableCell.swift
//  Reach
//
//  Copyright © 2019 Netsolutions. All rights reserved.
//

import UIKit
import Kingfisher

class RequestFriendTableCell: UITableViewCell {

    // MARK: - IBOutlets
    @IBOutlet weak var imgVwFriend: UIImageView!

    @IBOutlet weak var lblFriendName: UILabel!

    @IBOutlet weak var btnImgFriend: UIButton!
    @IBOutlet weak var lblUsername: UILabel!

    @IBOutlet weak var btnSelect: UIButton!

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
        lblUsername.text = friend.username
        btnSelect.isSelected = friend.isSelected

        guard let isInvited = friend.isInvited else { return }

        if isInvited {
            btnSelect.isUserInteractionEnabled = false
            self.backgroundColor = #colorLiteral(red: 0.9450980392, green: 0.9450980392, blue: 0.9450980392, alpha: 1)

        } else {
            btnSelect.isUserInteractionEnabled = true
            self.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
    }
}
