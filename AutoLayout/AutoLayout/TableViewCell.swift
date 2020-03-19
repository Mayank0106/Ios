//
//  TableViewCell.swift
//  AutoLayout
//
//  Created by Mayank Sharma on 23/01/20.
//  Copyright © 2020 Mayank Sharma. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var lblName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
