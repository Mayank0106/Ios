//
//  UserTableView.swift
//  Zepplin
//
//  Created by Mayank Sharma on 27/02/20.
//  Copyright © 2020 Mayank Sharma. All rights reserved.
//

import UIKit
struct Country {
    
    var Abc: String
    var name: String
    
}
class UserTableView: UITableViewCell {
    
    
    @IBOutlet weak var titlelbl: UILabel!
    @IBOutlet weak var Img: UIImageView!
    @IBOutlet weak var txtlbl: UILabel!


    let countries = [Country(Abc: "Mayank" , name: "Sharma")]

    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        // Initialization code
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath) as! UserTableView
        
        let country = countries[indexPath.row]
        cell.txtlbl?.text = country.name
        cell.titlelbl?.text = country.Abc
        cell.Img?.image = UIImage(named: #imageLiteral(resourceName: "download").Abc)
        
        return cell
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
