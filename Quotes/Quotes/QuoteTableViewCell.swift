//
//  QuoteTableViewCell.swift
//  Quotes
//
//  Created by Mayank Sharma on 18/02/20.
//  Copyright © 2020 Mayank Sharma. All rights reserved.
//

import UIKit


class QuoteTableViewCell: UITableViewCell {
    
    
    
    
    static let reuseIdentifier = "QuoteCell"
    
    
    
    @IBOutlet var authorLabel: UILabel!
    @IBOutlet var contentsLabel: UILabel!


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
