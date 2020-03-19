//
//  UserTableViewCell.swift
//  Table View
//
//  Created by Mayank Sharma on 12/02/20.
//  Copyright © 2020 Mayank Sharma. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var btnSelection: UIButton!
    @IBOutlet weak var lblDescption: UILabel!
    
    //CompletionHandler
    var buttonTapped : (() -> ())? 
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        // Add action to perform when the button is tapped
        self.btnSelection.addTarget(self, action: #selector(bSelection(_:)), for: .touchUpInside)
    }
    @IBAction func bSelection(_ sender: UIButton) {
        
        buttonTapped!()
        
    }
    
   
    func setData(userSelection: UserSelection) {
        self.name.text = userSelection.name
        self.lblDescption.text = userSelection.description
        
        if userSelection.isSelected {
          self.btnSelection.setImage(#imageLiteral(resourceName: "icSelected"), for: .normal)
        }
        else
        {
            self.btnSelection.setImage(#imageLiteral(resourceName: "tick"), for: .normal)
        }
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
   
    
}







