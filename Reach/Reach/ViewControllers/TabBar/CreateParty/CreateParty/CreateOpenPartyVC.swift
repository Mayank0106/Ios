//
//  CreateOpenPartyVC.swift
//  Reach
//
//  Copyright © 2019 Netsolutions. All rights reserved.
//

import UIKit

class CreateOpenPartyVC: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var txtPartyName: FloatLabelTextField!

    @IBOutlet weak var btnNext: UIButton!

    @IBOutlet weak var lblBannerSmall: UILabel!

    @IBOutlet weak var lblBannerBig: UILabel!

    @IBOutlet weak var btnBannerImage: UIButton!

    @IBOutlet weak var imgVwBanner: UIImageView!

    @IBOutlet weak var imgOverlay: UIImageView!

    @IBOutlet weak var constraintNavBarHt: NSLayoutConstraint!

    // MARK: - Variables

    // Handler of AWS Utility to show that images are uploaded
    var objectAWSProtocol: AWSProtocol?

    // Event Type from Segue - Define Event
    var eventType: Int?

    let maxPartyNameLength = 60

    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        enableNextButton(shouldEnable: false)
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

    override func viewWillAppear(_ animated: Bool) {

        setNavBarHide(hide: true)
    }

    // MARK: - Set up UI

    /// Enable Next Button
    ///
    /// - Parameter shouldEnable: should enable
    func enableNextButton(shouldEnable: Bool) {

        if shouldEnable {
            btnNext.isUserInteractionEnabled = true
            btnNext.alpha = 1
        } else {
            btnNext.isUserInteractionEnabled = false
            btnNext.alpha = 0.5
        }
    }

    /// Animate Navigation Bar
    ///
    /// - Parameter withCopnstant: constant value
    func animateNavBar(withCopnstant: CGFloat) {

        UIView.animate(withDuration: 0.5,
                       delay: 0.1,
                       options: UIViewAnimationOptions.curveEaseIn,
                       animations: { () -> Void in
                        self.constraintNavBarHt.constant = withCopnstant
                        self.view.updateConstraints()
                        self.view.layoutIfNeeded()
        }, completion: { (finished) -> Void in
            // ....
        })
    }

    // MARK: - Validate Fields

    /// Validate All Fields
    ///
    /// - Returns: Status
    func validateAllFields() -> (Bool, String?) {

        if txtPartyName.text!.isEmpty {
            return (false, "Enter party name")

        } else if imgVwBanner.image == nil {
            return (false, "PleaseSelectBannerImage".localized)

        }
        return (true, nil)
    }

    // MARK: - IBActions

    @IBAction func btnSelectBannerAction(_ sender: Any) {

        lblBannerSmall.isHidden = false
        lblBannerBig.isHidden = true

        // Allow user to select Banner Image
        self.objectAWSProtocol = AWSProtocol(resizeHandler: { (_, resizedThumbImage) in

            self.imgVwBanner.image = resizedThumbImage
            self.imgOverlay.isHidden = false
            let tuple = self.validateAllFields()
            self.enableNextButton(shouldEnable: tuple.0)

        }, onComplete: { (_, _) in
            print("Download complete")
        })

        self.objectAWSProtocol?.showActionSheetForImage(controller: self)
    }

    @IBAction func btnBackArrowAction(_ sender: Any) {

        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func btnNextArrowAction(_ sender: Any) {

        self.view.endEditing(true)

        self.performSegue(withIdentifier: "CreatePartyDetailSegue",
                          sender: nil)
    }

    // MARK: - Prepare For Segue
    override func prepare(for segue: UIStoryboardSegue,
                          sender: Any?) {

        if segue.identifier == "CreatePartyDetailSegue" {

            guard let partyDetailVC = segue.destination as? CreatePartyDetailVC else { return }
            partyDetailVC.eventType = eventType
            partyDetailVC.eventName = txtPartyName.text!
            partyDetailVC.eventBanner = self.imgVwBanner.image

        }
    }
}

// MARK: - UITextField delagate methods
extension CreateOpenPartyVC: UITextFieldDelegate {

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {

        let strText = textField.text! as NSString

        let newText = strText.replacingCharacters(in: range,
                                                  with: string)

        if textField == txtPartyName {

            if newText.length > maxPartyNameLength {
                return false
            }
        }
        textField.text = newText
        let tuple = validateAllFields()
        enableNextButton(shouldEnable: tuple.0)
        return false
    }
}
