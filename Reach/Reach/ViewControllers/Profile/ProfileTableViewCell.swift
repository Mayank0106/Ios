//
//  ProfileTableViewCell.swift
//  Reach
//
//  Copyright © 2019 Netsolutions. All rights reserved.
//

import UIKit
import Kingfisher

class ProfileTableViewCell: UITableViewCell {

    // MARK: - IBOutlets
    @IBOutlet weak var vwOuter: UIView!

    @IBOutlet weak var imgVwBanner: UIImageView!

    @IBOutlet weak var imgVwHost: UIImageView!

    @IBOutlet weak var lblPartyName: UILabel!

    @IBOutlet weak var lblPartyDate: UILabel!

    @IBOutlet weak var vwDot: UIView!

    @IBOutlet weak var lblPartyTime: UILabel!

    @IBOutlet weak var lblNoOfPeopleGoing: UILabel!

    // MARK: - Initialization Methods
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
        if let goingCount = feed.goingCount {
             lblNoOfPeopleGoing.text = String(goingCount) + " people"
        }

    }
}
