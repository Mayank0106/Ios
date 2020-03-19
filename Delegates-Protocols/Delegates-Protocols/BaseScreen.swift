//
//  ViewController.swift
//  Delegates-Protocols
//
//  Created by Mayank Sharma on 06/02/20.
//  Copyright © 2020 Mayank Sharma. All rights reserved.
//

import UIKit

class BaseScreen: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var chooseButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chooseButton.layer.cornerRadius = chooseButton.frame.size.height/2
        // Do any additional setup after loading the view, typically from a nib.
    }
    @IBAction func chooseButtonTapped(_ sender: UIButton) {
        let storyBoard = UIStoryboard(name: "Main", bundle:nil)
        let selectionVC = storyBoard.instantiateViewController(withIdentifier: "SelectionScreen") as! SelectionScreen
        selectionVC.selectionDelegate = self
        present(selectionVC, animated: true, completion: nil)
    }
}

extension BaseScreen: SideSelectionDelegate{
    func didTapChoice(image: UIImage, name: String, color: UIColor) {
        mainImageView.image = image
        nameLabel.text = name
        view.backgroundColor = color
    }
}
    