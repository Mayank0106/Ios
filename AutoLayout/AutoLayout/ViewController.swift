//
//  ViewController.swift
//  AutoLayout
//
//  Created by Mayank Sharma on 22/01/20.
//  Copyright © 2020 Mayank Sharma. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // Data model: These strings will be the data for the table view cells
    let animals: [String] = ["Horse1", "Co1w", "Cow1w"]
    
    // cell reuse id (cells that scroll out of view can be reused)
    let cellReuseIdentifier = "TableViewCell"
    
    // don't forget to hook this up from the storyboard
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register the table view cell class and its reuse id
//        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        
        // (optional) include this line if you want to remove the extra empty cell divider lines
        // self.tableView.tableFooterView = UIView()
        
        // This view controller itself will provide the delegate methods and row data for the table view.
        tableView.delegate = self
        tableView.dataSource = self
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
             return self.animals.count - 1
        } else {
            return self.animals.count
        }
       
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        let cell:TableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! TableViewCell!
        
        // set the text from the data model
        cell.lblName?.text = self.animals[indexPath.row]
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var vw: UIView = UIView()
        vw.frame = CGRect(x: 0 , y: 0 , width: UIScreen.main.bounds.width ?? 0, height: 44)
        vw.backgroundColor = .red
        
        var lbl: UILabel = UILabel()
         lbl.frame = vw.frame
        lbl.text = "section \(section)"
        vw.addSubview(lbl)
        return vw
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
    }
}

