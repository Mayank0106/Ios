//
//  HomeVC.swift
//  Reach
//
//  Copyright © 2018 Netsolutions. All rights reserved.
//

import UIKit

class HomeVC: UIViewController {

    // MARK: - View Controller life cycle

    override func viewDidLoad() {

        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {

        setNavBarHide(hide: true)
    }

    // MARK: - IBActions

    @IBAction func btnSignUpAction(_ sender: Any) {
        performSegue(withIdentifier: StoryboardSegue.Main.toSignUpVC.rawValue, sender: self)
    }

    @IBAction func btnSignInAction(_ sender: Any) {
         performSegue(withIdentifier: StoryboardSegue.Main.toSignInVC.rawValue, sender: self)
    }
}
