//
//  SelectionScreen.swift
//  Delegates-Protocols
//
//  Created by Mayank Sharma on 06/02/20.
//  Copyright © 2020 Mayank Sharma. All rights reserved.
//

import UIKit
protocol SideSelectionDelegate {
    func didTapChoice(image: UIImage, name: String, color: UIColor)
}

class SelectionScreen: UIViewController {
 
    var selectionDelegate: SideSelectionDelegate!
    
    override func viewDidLoad() {
       super.viewDidLoad()
}
@IBAction func imperialButtonTapped(_ sender: UIButton) {
    selectionDelegate.didTapChoice(image: UIImage(named: "vader")!, name: "Darth vader", color: .red)
      dismiss(animated: true, completion: nil)
    
    }

    @IBAction func rebelButtonTapped(_sender: UIButton) {
        selectionDelegate.didTapChoice(image: UIImage(named: "sw")!, name: "rebel", color: .cyan)
        dismiss(animated: true, completion: nil)
  }


}






