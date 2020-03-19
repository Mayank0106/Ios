//
//  ViewControllerExtension.swift

import Foundation
import UIKit
import SVProgressHUD
import Kingfisher

enum NavigationBarButtons {

    case backButton
    case doneButton
    case profile
    case settings
    case none
}

extension UIViewController {

    /// Set Nav bar title
    ///
    /// - Parameters:
    ///   - title: title
    ///   - leftBarItem: left bar buttons
    ///   - rightBarItems: right bar buttons
    func setNavBar(title: String, leftBarItem: NavigationBarButtons, rightBarItems: [NavigationBarButtons]) {

        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationItem.title = title

        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.07726221532, green: 0.07726515085, blue: 0.07726357132, alpha: 1)
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)

        setLeftBarButtonItems(leftBarItem: leftBarItem)

        setRightBarButtonItems(rightBarItems: rightBarItems)

    }

    /// Set Left Bar Button
    ///
    /// - Parameter leftBarItem: left bar button
    func setLeftBarButtonItems(leftBarItem: NavigationBarButtons) {

        switch leftBarItem {

        case .backButton:
            self.navigationItem.leftBarButtonItem =
                UIBarButtonItem(image: UIImage(named: "backImage"), style: .plain, target: self, action: #selector(backAction(sender:)))

        case .doneButton:
             self.navigationItem.leftBarButtonItem =
                UIBarButtonItem(title: "DONE", style: .plain, target: self, action: #selector(backAction(sender:)))
             self.navigationItem.leftBarButtonItem?
                .setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "Helvetica Bold", size: 16)!], for: .normal)

        default :
            self.navigationItem.hidesBackButton = true

        }
    }

    /// Set Right Bar Buttons
    ///
    /// - Parameter rightBarItems: right bar buttons
    func setRightBarButtonItems(rightBarItems: [NavigationBarButtons]) {

        var rightBarButtonItems = [UIBarButtonItem]()
        for rightBaritem in rightBarItems {

            switch rightBaritem {

                case .profile:
                    addImageAsRightBarButton()

                case .settings:
                    let settings = UIBarButtonItem(image: UIImage(named: "iconSettings"), style: .plain, target: self, action: #selector(settingsAction(sender:)))
                    rightBarButtonItems.append(settings)

            default: break

            }
        }

        self.navigationItem.rightBarButtonItems = rightBarButtonItems
    }

    @objc func settingsAction(sender: UIButton) {

        self.performSegue(withIdentifier: "fromProfileToSettingsSegue", sender: nil)
    }

    @objc func backAction(sender: UIButton) {

        self.navigationController?.popViewController(animated: true)
    }

    func profileAction(userID: Int?) {

        guard let tabbarController = appDelegate.window?.rootViewController
            as? UITabBarController else { return }

        guard let vc = tabBarStoryboard.instantiateViewController(withIdentifier: "ProfileNavController")
            as? UINavigationController else { return }

        guard let profileVC = vc.viewControllers[0] as? ProfileVC else { return }

        profileVC.userID = userID
        vc.modalPresentationStyle = .overCurrentContext
        tabbarController.present(vc, animated: false) { () -> Void in
            vc.view.frame = CGRect(x: 0, y: -vc.view.frame.height, width: vc.view.frame.width, height: vc.view.frame.height)
            vc.view.alpha = 1
            UIView.animate(withDuration: 0.5,
                           animations: { () -> Void in
                            vc.view.frame = CGRect(x: 0, y: 0, width: vc.view.frame.width, height: vc.view.frame.height)
            },
                           completion: nil)
        }
    }

    func setNavBarHide(hide: Bool) {

        self.navigationController?.setNavigationBarHidden(hide, animated: false)

    }

    // Show loader depending on usr interaction
    func showLoader() {
        self.view.isUserInteractionEnabled = false
        SVProgressHUD.setDefaultStyle(.custom)
        SVProgressHUD.setBackgroundColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5))
        SVProgressHUD.setForegroundColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
        SVProgressHUD.show()
    }

    /// Dismiss loader
    func dismissLoader() {

        self.view.isUserInteractionEnabled = true
        SVProgressHUD.dismiss()

    }

    func addImageAsRightBarButton() -> UIButton {

        let button = UIButton.init(type: .custom)

        button.addTarget(self, action: #selector(settingsAction(sender:)), for: .touchUpInside)
        button.frame = CGRect.init(x: 0, y: 0, width: 34, height: 34) //CGRectMake(0, 0, 30, 30)
        return button

    }
}
