//
//  EventsToEditTableCell.swift
//  Reach
//
//  Copyright © 2019 Netsolutions. All rights reserved.
//

import UIKit
import Kingfisher

protocol EditEventProtocol {
    func editEvent(eventID: Int)
}

class EventsToEditTableCell: UITableViewCell {

    // MARK: - IBOutlets
    @IBOutlet weak var imgVwPic: UIImageView!

    @IBOutlet weak var lblEventName: UILabel!

    @IBOutlet weak var lblEventType: UILabel!

    @IBOutlet weak var btnEdit: UIButton!

    // MARK: - Protocol Variable
    var delegateEditEvent: EditEventProtocol?

    // MARK: - Initial Calls
    override func awakeFromNib() {

        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool,
                              animated: Bool) {
        super.setSelected(selected,
                          animated: animated)

        // Configure the view for the selected state
    }

    // MARK: - Set Content To Cell

    /// Set Content To Cell
    ///
    /// - Parameter objEvent: Event Model
    func setContentToCell(objEvent: MyEventModel) {

        if let bannerImageStr = objEvent.bannerImage,
            let bannerImageUrl = URL(string: bannerImageStr) {
            imgVwPic.kf.setImage(with: ImageResource(downloadURL: bannerImageUrl),
                                 placeholder: UIImage(named: "avatarImage"),
                                 options: [KingfisherOptionsInfoItem.cacheMemoryOnly],
                                 progressBlock: nil,
                                 completionHandler: nil)
        }
        lblEventName.text = objEvent.name
        if objEvent.eventType == 1 {
            lblEventType.text = "OpenEvent".localized
        } else {
            lblEventType.text = "ClosedEvent".localized
        }
        guard let eventId = objEvent.id else { return }
        btnEdit.tag = eventId
    }

    // MARK: - IBActions
    @IBAction func btnEditAction(_ sender: Any) {

        guard let btnEdit = sender as? UIButton else { return }
        delegateEditEvent?.editEvent(eventID: btnEdit.tag)
    }

}
