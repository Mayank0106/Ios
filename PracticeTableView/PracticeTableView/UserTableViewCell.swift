//
//  UserTableViewCell.swift
//  PracticeTableView
//
//  Created by Mayank Sharma on 13/02/20.
//  Copyright © 2020 Mayank Sharma. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {

  @IBOutlet weak var Name: UILabel!
  @IBOutlet weak var lblDescription: UILabel!
  @IBOutlet weak var imgViewSelection: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setData(userSelection: UserSelection) {
        self.Name.text = userSelection.name
        self.lblDescription.text = userSelection.description
    
    if userSelection.isSelected {
         self.imgViewSelection.isHidden = false
    }
    else {
            self.imgViewSelection.isHidden = true
        }
    }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

