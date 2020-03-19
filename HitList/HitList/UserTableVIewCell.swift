//
//  UserTableVIewCell.swift
//  HitList
//
//  Created by Mayank Sharma on 19/02/20.
//  Copyright © 2020 Mayank Sharma. All rights reserved.
//

import UIKit

class UserTableVIewCell: UITableViewCell {
    
    @IBOutlet weak var btnSelection: UIButton!
    @IBOutlet weak var lblPersonName: UILabel!
    @IBOutlet weak var updateSelection: UIButton!
    
    //Completion Handler
    
    var subscribeButtonAction : (() -> ())?
    var updateButtonAction : (() -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        // Add action when button is tapped
        self.btnSelection.addTarget(self, action: #selector(bSelection(_:)), for: .touchUpInside)
        self.updateSelection.addTarget(self, action: #selector(upSelection(_:)), for: .touchUpInside)
    }
    

    @IBAction func bSelection(_: UIButton) {
        subscribeButtonAction!()
    }
    
    
    @IBAction func upSelection(_ sender: UIButton) {
        
        updateButtonAction!()
        
}
    
    
    
    
    /*func setData(userSelection: UserSelection) {
        
        if userSelection.isSelected {
  
           self.btnSelection.setImage(#imageLiteral(resourceName: "tick"), for: .normal)
           
        }
        else
        {
            self.btnSelection.setImage(#imageLiteral(resourceName: "tick"), for: .normal)
        }
    }*/
    
  
        override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
