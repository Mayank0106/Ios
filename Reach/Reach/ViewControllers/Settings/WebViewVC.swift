//
//  WebViewVC.swift
//  Reach
//
//  Copyright © 2019 Netsolutions. All rights reserved.
//

import UIKit

enum PageToOpen {
    case terms
    case privacy
    case aboutUs
}

class WebViewVC: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var webView: UIWebView!

    // MARK: - Variables

    var objPageToOpen: PageToOpen?

    // MARK: - View controller life cycle
    override func viewDidLoad() {

        super.viewDidLoad()

        setNavBar()
        loadWebView()
        // Do any additional setup after loading the view.
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(gesture:)))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
    }
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                _ = self.navigationController?.popViewController(animated: true)
            default:
                break
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidDisappear(_ animated: Bool) {

        dismissLoader()
    }

    // MARK: - Set UI Elements

    /// Set Nav Bar
    func setNavBar() {

        guard let objPageToOpen = objPageToOpen else { return }
        switch objPageToOpen {
        case .terms:
            setNavBar(title: "TermsAndConditions".localized,
                      leftBarItem: NavigationBarButtons.doneButton,
                      rightBarItems: [NavigationBarButtons.none])
        case .privacy:
            setNavBar(title: "PrivacyPolicy".localized,
                      leftBarItem: NavigationBarButtons.doneButton,
                      rightBarItems: [NavigationBarButtons.none])
        case .aboutUs:
            setNavBar(title: "AboutUs".localized,
                      leftBarItem: NavigationBarButtons.doneButton,
                      rightBarItems: [NavigationBarButtons.none])
        }
    }

    /// Load request in web view as per call
    func loadWebView() {
        guard let objPageToOpen = objPageToOpen else { return }
        switch objPageToOpen {
        case .terms:
           webView.loadRequest(URLRequest(url: URL(string: Configuration.termsAndConditionsURL())!))
        case .privacy:
           webView.loadRequest(URLRequest(url: URL(string: Configuration.privacyPolicyURL())!))
        case .aboutUs:
           webView.loadRequest(URLRequest(url: URL(string: Configuration.aboutUsURL())!))
        }
    }
}

// MARK: - UIWebView Delegate methods
extension WebViewVC: UIWebViewDelegate {

    func webViewDidStartLoad(_ webView: UIWebView) {
        showLoader()
    }

    func webViewDidFinishLoad(_ webView: UIWebView) {
        dismissLoader()
    }
}
