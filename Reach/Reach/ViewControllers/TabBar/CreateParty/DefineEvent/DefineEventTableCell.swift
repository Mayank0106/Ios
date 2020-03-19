//
//  DefineEventTableCell.swift
//  Reach
//
//  Copyright © 2019 Netsolutions. All rights reserved.
//

import UIKit

protocol SelectEventAction: class {
    func selectEventType(eventType: Int)
}

class DefineEventTableCell: UITableViewCell {

    // MARK: - IBOutlets
    weak var delegateSelectEvent: SelectEventAction?

    // MARK: - Initial Calls
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    // MARK: - IBActions
    @IBAction func btnCloseEventAction(_ sender: Any) {

        delegateSelectEvent?.selectEventType(eventType: 2)
    }

    @IBAction func btnOpenEventAction(_ sender: Any) {
        delegateSelectEvent?.selectEventType(eventType: 1)
    }
}
