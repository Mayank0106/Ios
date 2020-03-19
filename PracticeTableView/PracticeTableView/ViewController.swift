//
//  ViewController.swift
//  PracticeTableView
//
//  Created by Mayank Sharma on 13/02/20.
//  Copyright © 2020 Mayank Sharma. All rights reserved.
//

import UIKit

struct UserSelection {
    var isSelected: Bool = false
    var id: Int = -1
    var name: String = ""
    var description: String = ""
}


class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
  
    var arrUserSelectionObj: [UserSelection] = [UserSelection]()
    
    @IBOutlet weak var tblViewData: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
         self.getDemo()
      self.tblViewData.reloadData()
       
        }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrUserSelectionObj.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "UserTableViewCell" ) as? UserTableViewCell else { return UITableViewCell() }
        cell.setData(userSelection: arrUserSelectionObj[indexPath.row])
        return(cell)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        arrUserSelectionObj[indexPath.row].isSelected = !arrUserSelectionObj[indexPath.row].isSelected
        self.tblViewData.reloadData()
    }
    
    func getDemo() {
        for index in  0..<20 {
            var userSelectionObj: UserSelection = UserSelection()
            userSelectionObj.isSelected = false
            userSelectionObj.id = index
            userSelectionObj.name = "index \(index)"
            userSelectionObj.description = "description \(index)"
            
            self.arrUserSelectionObj.append(userSelectionObj)
            
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

